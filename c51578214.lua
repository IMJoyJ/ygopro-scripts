--騎甲虫アサルト・ローラー
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，③的效果1回合只能使用1次。
-- ①：这张卡可以把自己墓地1只昆虫族怪兽除外，从手卡特殊召唤。
-- ②：这张卡的攻击力上升自己场上的其他的昆虫族怪兽数量×200。
-- ③：这张卡被战斗破坏时才能发动。从卡组把「骑甲虫 突击滚球兵」以外的1只「骑甲虫」怪兽加入手卡。
function c51578214.initial_effect(c)
	-- ①：这张卡可以把自己墓地1只昆虫族怪兽除外，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,51578214+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c51578214.spcon)
	e1:SetTarget(c51578214.sptg)
	e1:SetOperation(c51578214.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力上升自己场上的其他的昆虫族怪兽数量×200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c51578214.atkup)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗破坏时才能发动。从卡组把「骑甲虫 突击滚球兵」以外的1只「骑甲虫」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetCountLimit(1,51578215)
	e3:SetTarget(c51578214.sctg)
	e3:SetOperation(c51578214.scop)
	c:RegisterEffect(e3)
end
-- 过滤满足条件的墓地昆虫族怪兽用于特殊召唤的cost
function c51578214.spcostfilter1(c)
	return c:IsAbleToRemoveAsCost() and c:IsRace(RACE_INSECT)
end
-- 判断是否可以发动①效果，检查是否有满足条件的墓地昆虫族怪兽
function c51578214.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否有可用怪兽区
	if Duel.GetMZoneCount(tp)<=0 then return false end
	-- 获取满足条件的墓地昆虫族怪兽组
	local g=Duel.GetMatchingGroup(c51578214.spcostfilter1,tp,LOCATION_GRAVE,0,nil)
	return #g>0
end
-- 设置①效果的发动选择目标，提示玩家选择要除外的卡
function c51578214.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足条件的墓地昆虫族怪兽组
	local g=Duel.GetMatchingGroup(c51578214.spcostfilter1,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行①效果的处理，将选定的卡除外
function c51578214.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	-- 将目标卡以特殊召唤理由除外
	Duel.Remove(sg,POS_FACEUP,REASON_SPSUMMON)
end
-- 过滤场上正面表示的昆虫族怪兽用于计算攻击力
function c51578214.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 计算并设置攻击力提升值
function c51578214.atkup(e,c)
	-- 获取场上正面表示的昆虫族怪兽数量并乘以200作为攻击力提升值
	return Duel.GetMatchingGroupCount(c51578214.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,e:GetHandler())*200
end
-- 过滤满足条件的卡组「骑甲虫」怪兽用于检索
function c51578214.filter(c)
	return c:IsSetCard(0x170) and c:IsType(TYPE_MONSTER) and not c:IsCode(51578214) and c:IsAbleToHand()
end
-- 设置③效果的发动条件，检查卡组是否有满足条件的卡
function c51578214.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足条件的「骑甲虫」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c51578214.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置③效果的操作信息，指定将要处理的卡的数量和位置
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行③效果的处理，从卡组选择一张符合条件的卡加入手牌
function c51578214.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的一张卡
	local g=Duel.SelectMatchingCard(tp,c51578214.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
