--背信聖徒シルヴィア
-- 效果：
-- 幻想魔族怪兽＋魔法师族·光属性怪兽
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：「背信圣徒 森厄狼母」以外的自己的「蓟花」怪兽给与对方的战斗伤害变成2倍。
-- ②：对方把魔法·陷阱·怪兽的效果发动时，把这张卡解放才能发动。那个效果无效。
-- ③：这张卡被战斗·效果破坏的场合才能发动。从卡组把1张「罪宝」陷阱卡加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果，设置融合召唤条件并注册三个效果
function s.initial_effect(c)
	-- 添加融合召唤手续，使用满足幻想魔族和光属性魔法师族的怪兽各1只为融合素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_ILLUSION),s.mfilter,true)
	c:EnableReviveLimit()
	-- 创建一个影响战斗伤害的效果，使己方「蓟花」怪兽对对方造成的战斗伤害变为2倍
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.damtg)
	-- 将该效果的战斗伤害值设置为双倍
	e1:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e1)
	-- 创建一个诱发即时效果，当对方发动魔法·陷阱·怪兽效果时可以无效该效果
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.discon)
	e2:SetCost(s.discost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	-- 创建一个诱发选发效果，当此卡被战斗或效果破坏时可以从卡组检索一张「罪宝」陷阱卡加入手牌
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 定义融合召唤所需的魔法师族光属性怪兽过滤函数
function s.mfilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_SPELLCASTER)
end
-- 定义战斗伤害改变效果的目标过滤函数，筛选己方「蓟花」怪兽（除自身外）
function s.damtg(e,c)
	return c:IsSetCard(0x1bc) and not c:IsCode(id)
end
-- 判断是否满足无效效果的条件，即对方发动效果且该效果可被无效
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方发动的效果不是自己发动的，并且该连锁效果可以被无效
	return ep~=tp and Duel.IsChainDisablable(ev)
end
-- 定义无效效果的费用函数，支付解放此卡的费用
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 实际执行解放此卡的操作
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 设置无效效果的目标函数，确认目标为被连锁的效果
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，标记将要使效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 定义无效效果的操作函数，使对应连锁效果无效
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 实际执行使连锁效果无效的操作
	Duel.NegateEffect(ev)
end
-- 判断是否满足检索效果的条件，即此卡因战斗或效果被破坏
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 定义检索「罪宝」陷阱卡的过滤函数
function s.thfilter(c)
	return c:IsSetCard(0x19e) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置检索效果的目标函数，检查卡组是否存在符合条件的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少一张符合条件的「罪宝」陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，标记将要从卡组检索一张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义检索效果的操作函数，选择并加入手牌，然后确认对方看到该卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示消息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「罪宝」陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方能看到被送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
