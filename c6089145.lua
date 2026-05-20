--クリアー・ウォール
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：场上有「清透世界」存在的场合才能发动。从卡组把有「清透世界」的卡名记述的1只怪兽加入手卡。
-- ②：有「清透世界」的卡名记述的怪兽不会被战斗破坏，那次战斗发生的对自己的战斗伤害变成0。
-- ③：只要有「清透世界」的卡名记述的7星以上的怪兽在自己场上存在，「清透世界」的效果不论属性而全部对对方适用。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①②③效果的注册
function s.initial_effect(c)
	-- 将「清透世界」（卡号33900648）加入到此卡的关联卡片密码列表中，用于支持相关检索和检测
	aux.AddCodeList(c,33900648)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：场上有「清透世界」存在的场合才能发动。从卡组把有「清透世界」的卡名记述的1只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：有「清透世界」的卡名记述的怪兽不会被战斗破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.indestg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	e5:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e5)
	-- ③：只要有「清透世界」的卡名记述的7星以上的怪兽在自己场上存在，「清透世界」的效果不论属性而全部对对方适用。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetRange(LOCATION_SZONE)
	e6:SetTargetRange(0,1)
	e6:SetCondition(s.ieecon)
	e6:SetCode(id)
	c:RegisterEffect(e6)
end
-- 效果①的发动条件判定函数
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在「清透世界」
	return Duel.IsEnvironment(33900648)
end
-- 效果①检索卡片的过滤条件函数
function s.thfilter(c)
	-- 过滤出卡组中记述有「清透世界」卡名的怪兽，且该怪兽可以加入手牌
	return aux.IsCodeListed(c,33900648) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的发动准备与目标确认函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足检索条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息，表示该效果会将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的执行操作函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②适用对象的过滤条件函数
function s.indestg(e,c)
	-- 过滤出记述有「清透世界」卡名的卡
	return aux.IsCodeListed(c,33900648)
end
-- 效果③适用条件中怪兽的过滤条件函数
function s.cfilter(c)
	-- 过滤出自己场上表侧表示、等级7以上且记述有「清透世界」卡名的怪兽
	return c:IsFaceup() and c:IsLevelAbove(7) and aux.IsCodeListed(c,33900648)
end
-- 效果③的适用条件判定函数
function s.ieecon(e)
	-- 检查自己场上是否存在满足条件的怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
