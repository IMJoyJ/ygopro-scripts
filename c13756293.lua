--竜魔人 キングドラグーン
-- 效果：
-- 「龙之支配者」＋「神龙 末日龙」
-- 只要这张卡在场上表侧表示存在，对方不能指定龙族为魔法·陷阱·怪兽的效果的对象。1回合1次，可以从手卡特殊召唤1只龙族怪兽到自己场上。
function c13756293.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以卡号17985575（「龙之支配者」）和卡号62113340（「神龙 末日龙」）为融合素材，sub与insf均为true，即允许融合素材代用品且素材顺序不限。
	aux.AddFusionProcCode2(c,17985575,62113340,true,true)
	-- ①：只要这张卡在怪兽区域存在，对方不能把场上的龙族怪兽作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置该“不能成为效果对象”保护效果的作用对象范围：场上所有龙族怪兽（被保护者限定为龙族）。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_DRAGON))
	-- 设置该保护效果的判定值：仅当效果发动者为这张卡的控制者的对手（rp不等于e:GetHandlerPlayer）时，该“不能成为对象”效果才适用。
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段才能发动。从手卡把1只龙族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(13756293,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c13756293.sptg)
	e2:SetOperation(c13756293.spop)
	c:RegisterEffect(e2)
end
-- 定义特殊召唤的候选怪兽过滤条件：必须是龙族怪兽，且能够被这个效果以表侧表示特殊召唤（检查召唤条件与苏生限制）。
function c13756293.filter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 起动效果的发动条件判定：自己主要阶段且场上有可用的主要怪兽区域，同时手卡存在1张以上满足特殊召唤条件的龙族怪兽。
function c13756293.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 先检查自己的主要怪兽区域是否有空位；若无空位则不能发动该特殊召唤效果。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 再检查手卡中是否存在至少1只满足c13756293.filter（龙族且可特殊召唤）的怪兽，作为效果发动的必要条件。
		and Duel.IsExistingMatchingCard(c13756293.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本次连锁的操作信息：该效果属于特殊召唤类别，预定从手卡特殊召唤1只怪兽，目标玩家为tp，位置为手卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理时的实际操作：先判定场地空位，再让玩家从手卡选择1只符合条件的龙族怪兽，将其表侧表示特殊召唤到自己场上。
function c13756293.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己的主要怪兽区域仍存在可用空格；若没有，则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给操作玩家弹出选择提示“请选择要特殊召唤的卡”，用于引导玩家进行后续选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1张满足过滤条件的龙族怪兽作为本次特殊召唤的对象；此时必定选择1张（min=1,max=1）。
	local g=Duel.SelectMatchingCard(tp,c13756293.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择成功的怪兽以表侧表示（POS_FACEUP）特殊召唤到操作者自己场上，sumtype=0且不无视召唤条件/苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
