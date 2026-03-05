--氷獄龍 トリシューラ
-- 效果：
-- 卡名不同的怪兽×3
-- 这张卡用只以自己的手卡·场上的怪兽为素材的融合召唤以及用以下方法才能从额外卡组特殊召唤。
-- ●把自己场上的上记卡除外的场合可以从额外卡组特殊召唤（不需要「融合」）。
-- ①：只用原本种族是龙族的怪兽作为素材让这张卡特殊召唤成功的场合才能发动。以自己卡组·对方卡组最上面·对方的额外卡组的顺序来确认并各让1张除外。这个卡名的这个效果1回合只能使用1次。
function c15661378.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用3个满足条件的卡作为融合素材
	aux.AddFusionProcFunRep(c,c15661378.ffilter,3,false)
	-- 添加接触融合特殊召唤规则，需要除外自己场上的卡才能从额外卡组特殊召唤
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_MZONE,0,Duel.Remove,POS_FACEUP,REASON_COST+REASON_MATERIAL):SetValue(SUMMON_VALUE_SELF)
	-- 效果原文：卡名不同的怪兽×3
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_MATERIAL_LIMIT)
	e0:SetValue(c15661378.matlimit)
	c:RegisterEffect(e0)
	-- 效果原文：这张卡用只以自己的手卡·场上的怪兽为素材的融合召唤以及用以下方法才能从额外卡组特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c15661378.splimit)
	c:RegisterEffect(e1)
	-- 效果原文：①：只用原本种族是龙族的怪兽作为素材让这张卡特殊召唤成功的场合才能发动。以自己卡组·对方卡组最上面·对方的额外卡组的顺序来确认并各让1张除外。这个卡名的这个效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(15661378,0))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,15661378)
	e3:SetCondition(c15661378.remcon)
	e3:SetTarget(c15661378.remtg)
	e3:SetOperation(c15661378.remop)
	c:RegisterEffect(e3)
	-- 效果原文：●把自己场上的上记卡除外的场合可以从额外卡组特殊召唤（不需要「融合」）
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(c15661378.valcheck)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
-- 融合素材过滤函数，确保融合素材中没有重复的融合卡号
function c15661378.ffilter(c,fc,sub,mg,sg)
	return not sg or not sg:IsExists(Card.IsFusionCode,1,c,c:GetFusionCode())
end
-- 限制融合素材只能来自自己场上或手牌
function c15661378.matlimit(e,c,fc,st)
	if st~=SUMMON_TYPE_FUSION then return true end
	return c:IsControler(fc:GetControler()) and c:IsLocation(LOCATION_ONFIELD+LOCATION_HAND)
end
-- 限制特殊召唤只能通过融合或接触融合方式
function c15661378.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
		or st&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION
end
-- 判断是否为龙族怪兽
function c15661378.mfilter(c)
	return c:GetOriginalRace()~=RACE_DRAGON
end
-- 检查融合素材中是否包含龙族怪兽，若无则标记为不可发动
function c15661378.valcheck(e,c)
	local mg=c:GetMaterial()
	if mg:GetCount()>0 and not mg:IsExists(c15661378.mfilter,1,nil) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 判断是否为接触融合或融合召唤成功，并且满足龙族条件
function c15661378.remcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF or c:IsSummonType(SUMMON_TYPE_FUSION)) and e:GetLabel()==1
end
-- 设置发动时的条件检查，确认是否能从自己卡组、对方卡组、对方额外卡组各除外一张卡
function c15661378.remtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在可除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_DECK,0,1,nil)
		-- 检查对方卡组是否存在可除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_DECK,1,nil)
		-- 检查对方额外卡组是否存在可除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,1,nil) end
	-- 设置连锁操作信息，表示将要除外卡牌
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_DECK+LOCATION_EXTRA)
end
-- 发动效果时执行的操作，从自己卡组、对方卡组最上方、对方额外卡组各除外一张卡
function c15661378.remop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有可除外的卡
	local g1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_DECK,0,nil)
	-- 获取对方卡组最上方的1张卡
	local g2=Duel.GetDecktopGroup(1-tp,1)
	-- 获取对方额外卡组中所有可除外的卡
	local g3=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,nil)
	if g1:GetCount()>0 and g2:GetCount()>0 and g3:GetCount()>0 then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg1=g1:Select(tp,1,1,nil)
		-- 确认对方卡组最上方的1张卡
		Duel.ConfirmDecktop(1-tp,1)
		-- 确认玩家查看对方额外卡组中的卡
		Duel.ConfirmCards(tp,g3)
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg3=g3:Select(tp,1,1,nil)
		sg1:Merge(g2)
		sg1:Merge(sg3)
		-- 将选中的卡除外
		Duel.Remove(sg1,POS_FACEUP,REASON_EFFECT)
		-- 将对方额外卡组洗切
		Duel.ShuffleExtra(1-tp)
	end
end
