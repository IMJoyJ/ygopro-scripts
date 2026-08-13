--氷獄龍 トリシューラ
-- 效果：
-- 卡名不同的怪兽×3
-- 这张卡用只以自己的手卡·场上的怪兽为素材的融合召唤以及用以下方法才能从额外卡组特殊召唤。
-- ●把自己场上的上记卡除外的场合可以从额外卡组特殊召唤（不需要「融合」）。
-- ①：只用原本种族是龙族的怪兽作为素材让这张卡特殊召唤成功的场合才能发动。以自己卡组·对方卡组最上面·对方的额外卡组的顺序来确认并各让1张除外。这个卡名的这个效果1回合只能使用1次。
function c15661378.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡注册融合召唤手续，要求使用3只满足 c15661378.ffilter 条件的怪兽作为融合素材，从而体现“卡名不同的怪兽×3”这一融合素材要求。
	aux.AddFusionProcFunRep(c,c15661378.ffilter,3,false)
	-- 为这张卡注册接触融合手续：可以将自己主要怪兽区满足可以除外作为代价的怪兽除外，作为融合素材从额外卡组特殊召唤，并将该召唤方式标记为自身效果/条件，对应“把自己场上的上记卡除外的场合可以从额外卡组特殊召唤（不需要「融合」）”的额外召唤方式。
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_MZONE,0,Duel.Remove,POS_FACEUP,REASON_COST+REASON_MATERIAL):SetValue(SUMMON_VALUE_SELF)
	-- 这段代码将融合素材限制为必须来自这张卡的控制者的手牌或场上，对应效果原文中的“用只以自己的手卡·场上的怪兽为素材的融合召唤”。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_MATERIAL_LIMIT)
	e0:SetValue(c15661378.matlimit)
	c:RegisterEffect(e0)
	-- 这段代码设置特殊召唤条件：这张卡在额外卡组时，只允许通过融合召唤（含接触融合）的方式特殊召唤，对应效果原文中的“这张卡用只以自己的手卡·场上的怪兽为素材的融合召唤以及用以下方法才能从额外卡组特殊召唤。”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c15661378.splimit)
	c:RegisterEffect(e1)
	-- 这段代码是①效果的发动、条件、目标与处理设定，对应效果原文：“①：只用原本种族是龙族的怪兽作为素材让这张卡特殊召唤成功的场合才能发动。以自己卡组·对方卡组最上面·对方的额外卡组的顺序来确认并各让1张除外。这个卡名的这个效果1回合只能使用1次。”
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
	-- 这段代码通过素材检查，确认特殊召唤是否只使用了原本种族为龙族的怪兽作为素材，对应效果原文中的“只用原本种族是龙族的怪兽作为素材让这张卡特殊召唤成功的场合”。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(c15661378.valcheck)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
-- 融合素材过滤函数：检查当前已选择的融合素材中是否存在与候选素材融合卡号相同的卡，从而保证选出的3只素材怪兽卡名各不相同。
function c15661378.ffilter(c,fc,sub,mg,sg)
	return not sg or not sg:IsExists(Card.IsFusionCode,1,c,c:GetFusionCode())
end
-- 融合素材限制函数：若不是融合召唤则不限制；若是融合召唤，则要求素材怪兽的控制者与融合怪兽相同，且素材必须来自手牌或场上，符合“只以自己的手卡·场上的怪兽为素材的融合召唤”的限制。
function c15661378.matlimit(e,c,fc,st)
	if st~=SUMMON_TYPE_FUSION then return true end
	return c:IsControler(fc:GetControler()) and c:IsLocation(LOCATION_ONFIELD+LOCATION_HAND)
end
-- 特殊召唤条件限制函数：当这张卡位于额外卡组时，只允许以融合召唤（包含接触融合）的方式特殊召唤，禁止通过其他特殊召唤方式从额外卡组出场。
function c15661378.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
		or st&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION
end
-- 过滤函数：判断一张卡的原本种族不是龙族，用于后续检测素材中是否含有非龙族怪兽。
function c15661378.mfilter(c)
	return c:GetOriginalRace()~=RACE_DRAGON
end
-- 素材检查回调：读取本次特殊召唤使用的素材组，若素材数量大于0且不存在原本种族非龙族的怪兽，则将关联的①效果标签设为1，否则设为0，以此记录是否满足“只用原本种族是龙族的怪兽作为素材”的条件。
function c15661378.valcheck(e,c)
	local mg=c:GetMaterial()
	if mg:GetCount()>0 and not mg:IsExists(c15661378.mfilter,1,nil) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- ①效果的发动条件：必须是通过接触融合（自身效果方式）或融合召唤成功，并且素材检查标签为1（即所有素材原本种族均为龙族），才能发动效果。
function c15661378.remcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF or c:IsSummonType(SUMMON_TYPE_FUSION)) and e:GetLabel()==1
end
-- 效果发动时的合法性检查：确认自己卡组有1张可除外的卡、对方卡组最上方有1张可除外的卡、对方额外卡组有1张可除外的卡，满足“各让1张除外”的前提。
function c15661378.remtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在至少1张可以被除外的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_DECK,0,1,nil)
		-- 检查对方卡组中是否存在至少1张可以被除外的卡（对方卡组最上方的那张）。
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_DECK,1,nil)
		-- 检查对方额外卡组中是否存在至少1张可以被除外的卡。
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,1,nil) end
	-- 设置本次连锁的操作信息为除外效果，预计除外数量为1，涉及区域为卡组和额外卡组，供系统与相关卡牌效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_DECK+LOCATION_EXTRA)
end
-- 效果处理整体：从自己卡组选1张、取对方卡组最上方1张、从对方额外卡组选1张，确认后将这3张卡一并除外，然后洗切对方额外卡组。
function c15661378.remop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有能被除外的卡，作为后续选择除外对象的候选组。
	local g1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_DECK,0,nil)
	-- 获取对方卡组最上方的1张卡（不取对象，固定为该张）。
	local g2=Duel.GetDecktopGroup(1-tp,1)
	-- 获取对方额外卡组中所有能被除外的卡，作为后续选择除外对象的候选组。
	local g3=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,nil)
	if g1:GetCount()>0 and g2:GetCount()>0 and g3:GetCount()>0 then
		-- 向己方玩家显示选择提示，提示内容为“请选择要除外的卡”（对应HINTMSG_REMOVE）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg1=g1:Select(tp,1,1,nil)
		-- 向对方玩家确认其卡组最上方的1张卡，满足“确认对方卡组最上面”的效果要求。
		Duel.ConfirmDecktop(1-tp,1)
		-- 向己方玩家展示对方额外卡组中所有可除外的候选卡，满足“确认对方的额外卡组”的效果要求。
		Duel.ConfirmCards(tp,g3)
		-- 再次向己方玩家显示选择提示，提示内容为“请选择要除外的卡”，用于从对方额外卡组中选择要除外的1张。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg3=g3:Select(tp,1,1,nil)
		sg1:Merge(g2)
		sg1:Merge(sg3)
		-- 将选出的自己卡组1张、对方卡组最上方1张、对方额外卡组1张怪兽一起以表侧表示除外，完成“各让1张除外”的效果处理。
		Duel.Remove(sg1,POS_FACEUP,REASON_EFFECT)
		-- 从对方额外卡组除外卡片后洗切对方的额外卡组，保证额外卡组顺序不可知。
		Duel.ShuffleExtra(1-tp)
	end
end
