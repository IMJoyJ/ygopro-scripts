--聖霊獣騎 ガイアペライオ
-- 效果：
-- 「圣灵兽骑」怪兽＋「灵兽使」怪兽＋「精灵兽」怪兽
-- 把自己场上的上记的卡除外的场合才能特殊召唤。
-- ①：这个方法特殊召唤的这张卡得到以下效果。
-- ●怪兽的效果·魔法·陷阱卡发动时，从手卡把1张「灵兽」卡除外才能发动。那个发动无效并破坏。
function c56655675.initial_effect(c)
	c:EnableReviveLimit()
	local mat_list={}
	for i=0,2 do
		-- 循环生成并向融合素材列表中添加「圣灵兽骑」、「灵兽使」和「精灵兽」怪兽的过滤条件函数
		table.insert(mat_list,aux.FilterBoolFunction(Card.IsFusionSetCard,0xb5|(0x1000<<i)))
	end
	-- 为这张卡添加融合素材为「圣灵兽骑」怪兽＋「灵兽使」怪兽＋「精灵兽」怪兽的融合召唤手续
	aux.AddFusionProcMix(c,false,false,table.unpack(mat_list))
	-- 添加接触融合的特殊召唤规则，要求将自己场上的上述素材正面表示除外作为特殊召唤的代价
	aux.AddContactFusionProcedure(c,c56655675.cfilter,LOCATION_MZONE,0,Duel.Remove,POS_FACEUP,REASON_COST):SetValue(SUMMON_VALUE_SELF)
	-- 把自己场上的上记的卡除外的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：这个方法特殊召唤的这张卡得到以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c56655675.condition)
	e2:SetOperation(c56655675.operation)
	c:RegisterEffect(e2)
	-- ●怪兽的效果·魔法·陷阱卡发动时，从手卡把1张「灵兽」卡除外才能发动。那个发动无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c56655675.discon)
	e3:SetCost(c56655675.discost)
	e3:SetTarget(c56655675.distg)
	e3:SetOperation(c56655675.disop)
	c:RegisterEffect(e3)
end
-- 过滤场上可以作为接触融合素材的「圣灵兽骑」、「灵兽使」或「精灵兽」怪兽，且这些卡必须能够因代价被除外
function c56655675.cfilter(c)
	return c:IsFusionSetCard(0x40b5,0x10b5,0x20b5)
		and c:IsAbleToRemoveAsCost()
end
-- 检查这张卡是否是通过自身接触融合的方法特殊召唤成功的
function c56655675.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 在这张卡上注册一个不会因暂时除外等情况重置的标记（Flag），用于标识其是通过自身方法特殊召唤的
function c56655675.operation(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(56655675,RESET_EVENT+RESETS_WITHOUT_TEMP_REMOVE,0,1)
end
-- 检查发动无效效果的条件：这张卡具有通过自身方法特召的标记、不是此卡自身的效果发动、此卡未被战斗破坏、对方发动了怪兽效果或魔法·陷阱卡，且该发动可以被无效
function c56655675.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(56655675)~=0
		and re~=e and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 检查连锁中发动的效果是否为怪兽效果或魔法·陷阱卡的发动，且该发动可以被无效
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 过滤手卡中可以作为代价除外的「灵兽」卡
function c56655675.filter(c)
	return c:IsSetCard(0xb5) and c:IsAbleToRemoveAsCost()
end
-- 效果发动的代价处理：检查并让玩家从手卡选择1张「灵兽」卡正面表示除外
function c56655675.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1张可以作为代价除外的「灵兽」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c56655675.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 给玩家发送提示信息，提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手卡选择1张满足过滤条件的「灵兽」卡
	local g=Duel.SelectMatchingCard(tp,c56655675.filter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡正面表示除外作为发动的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果发动的目标处理：设置使发动无效并破坏的操作信息
function c56655675.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为“使发动无效”，目标为触发效果的卡
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若触发效果的卡可以被破坏且仍与效果相关联，则设置操作信息为“破坏”
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果发动的具体处理：使该发动无效，并将其破坏
function c56655675.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试使该连锁的发动无效，若成功且该卡仍与效果相关联，则进行后续处理
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 因效果将该卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
