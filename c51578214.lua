--騎甲虫アサルト・ローラー
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，③的效果1回合只能使用1次。
-- ①：这张卡可以把自己墓地1只昆虫族怪兽除外，从手卡特殊召唤。
-- ②：这张卡的攻击力上升自己场上的其他的昆虫族怪兽数量×200。
-- ③：这张卡被战斗破坏时才能发动。从卡组把「骑甲虫 突击滚球兵」以外的1只「骑甲虫」怪兽加入手卡。
function c51578214.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：这张卡可以把自己墓地1只昆虫族怪兽除外，从手卡特殊召唤。
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
	-- 这个卡名的③的效果1回合只能使用1次。③：这张卡被战斗破坏时才能发动。从卡组把「骑甲虫 突击滚球兵」以外的1只「骑甲虫」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetCountLimit(1,51578215)
	e3:SetTarget(c51578214.sctg)
	e3:SetOperation(c51578214.scop)
	c:RegisterEffect(e3)
end
-- 筛选可作为特殊召唤cost的卡：必须能够除外且是昆虫族怪兽。
function c51578214.spcostfilter1(c)
	return c:IsAbleToRemoveAsCost() and c:IsRace(RACE_INSECT)
end
-- 特殊召唤规则条件：该卡在手牌且满足有可用的怪兽区、墓地有可作为cost的昆虫族怪兽时，才能以此方式特殊召唤。
function c51578214.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 若自己场上没有可用的怪兽区（空位），则无法通过①的效果进行特殊召唤，条件不成立。
	if Duel.GetMZoneCount(tp)<=0 then return false end
	-- 获取自己墓地中所有可作为cost的昆虫族怪兽，作为特殊召唤的除外候选。
	local g=Duel.GetMatchingGroup(c51578214.spcostfilter1,tp,LOCATION_GRAVE,0,nil)
	return #g>0
end
-- 特殊召唤规则的选择阶段：从墓地候选中选择1只昆虫族怪兽作为要除外的cost；选中后存入效果对象供后续处理使用。
function c51578214.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中可作为cost的昆虫族怪兽候选组（供玩家选择）。
	local g=Duel.GetMatchingGroup(c51578214.spcostfilter1,tp,LOCATION_GRAVE,0,nil)
	-- 显示“请选择要除外的卡”的选择提示，引导玩家选择除外对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的实际处理：取出在Target阶段选择的cost卡，并执行除外操作。
function c51578214.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	-- 将作为cost选择的怪兽以表侧表示除外，完成①的特殊召唤手续中的cost处理。
	Duel.Remove(sg,POS_FACEUP,REASON_SPSUMMON)
end
-- ②效果的攻击力上升筛选条件：场上表侧表示且种族为昆虫族的怪兽（自身除外）。
function c51578214.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 计算②效果的攻击力上升数值：自己场上其他表侧表示昆虫族怪兽数量×200。
function c51578214.atkup(e,c)
	-- 统计满足②条件的昆虫族怪兽数量并乘以200，得到攻击力上升值。
	return Duel.GetMatchingGroupCount(c51578214.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,e:GetHandler())*200
end
-- ③效果的检索过滤条件：是「骑甲虫」系列的怪兽卡，不是「骑甲虫 突击滚球兵」自身，并且能够加入手卡。
function c51578214.filter(c)
	return c:IsSetCard(0x170) and c:IsType(TYPE_MONSTER) and not c:IsCode(51578214) and c:IsAbleToHand()
end
-- ③效果的发动条件和操作信息设置：确认卡组存在可检索的「骑甲虫」怪兽，并告知系统将进行从卡组加入手卡的处理。
function c51578214.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组中是否存在至少1张符合条件的「骑甲虫」怪兽，满足条件才可发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c51578214.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果处理信息：将卡组中的1张卡加入手卡（不取对象，由效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果的实际处理：从卡组选择1张符合条件的「骑甲虫」怪兽加入手卡，并让对方确认。
function c51578214.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的提示，让玩家选择检索目标。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选出1张满足条件的「骑甲虫」怪兽作为加入手牌的对象。
	local g=Duel.SelectMatchingCard(tp,c51578214.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「骑甲虫」怪兽加入持有者的手卡（原因记为效果）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
