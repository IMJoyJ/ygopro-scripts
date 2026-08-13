--守護竜ピスティ
-- 效果：
-- 4星以下的龙族怪兽1只
-- 自己对「守护龙 毗斯缇」1回合只能有1次特殊召唤，那个②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己不是龙族怪兽不能特殊召唤。
-- ②：以自己的墓地·除外状态的1只龙族怪兽为对象才能发动。那只怪兽在作为受2只以上的连接怪兽所连接区的自己场上特殊召唤。
function c13143275.initial_effect(c)
	c:SetSPSummonOnce(13143275)
	c:EnableReviveLimit()
	-- 为这张卡注册连接召唤手续：用1只等级4以下且可用作龙族连接素材的怪兽作为素材进行连接召唤。
	aux.AddLinkProcedure(c,c13143275.matfilter,1,1)
	-- ①：只要这张卡在怪兽区域存在，自己不是龙族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c13143275.splimit)
	c:RegisterEffect(e1)
	-- ②：以自己的墓地·除外状态的1只龙族怪兽为对象才能发动。那只怪兽在作为受2只以上的连接怪兽所连接区的自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(13143275,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,13143275)
	e2:SetTarget(c13143275.sptg)
	e2:SetOperation(c13143275.spop)
	c:RegisterEffect(e2)
end
-- 定义连接素材过滤条件：怪兽必须是等级4以下，并且作为连接素材时属于龙族；对应“4星以下的龙族怪兽1只”的素材要求。
function c13143275.matfilter(c)
	return c:IsLevelBelow(4) and c:IsLinkRace(RACE_DRAGON)
end
-- 定义①效果的限制条件：若被特殊召唤的怪兽不是龙族，则禁止该特殊召唤；即此卡在怪兽区域时，自己只能特殊召唤龙族怪兽。
function c13143275.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsRace(RACE_DRAGON)
end
-- 定义辅助过滤条件：表侧表示的连接怪兽；用于判断哪些连接怪兽可能提供连接区。
function c13143275.lkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
-- 定义②效果可选对象的过滤条件：自己墓地或除外状态的龙族怪兽，且该怪兽可以被特殊召唤到目标多连指区域。
function c13143275.spfilter(c,e,tp,zone)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- ②效果的发动条件和取对象处理：需要有被2只以上连接怪兽所指的可用格子、自己场上有可用怪兽区域，且墓地·除外存在符合条件的龙族怪兽；满足时由玩家选择对象。
function c13143275.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取玩家tp场上所有被2只以上连接怪兽所指向的格子（位掩码），作为特殊召唤的目标区域。
	local zone=aux.GetMultiLinkedZone(tp)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c13143275.spfilter(chkc,e,tp,zone) end
	-- 效果发动条件之一：存在多连指区域（zone不为0）且自己场上有可用的怪兽区域。
	if chk==0 then return zone~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果发动条件之二：自己墓地·除外区域存在至少1只满足spfilter条件的龙族怪兽可以作为对象。
		and Duel.IsExistingTarget(c13143275.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp,zone) end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示消息，用于选择对象时的界面提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地·除外状态的龙族怪兽中选择1只作为效果对象，并将其设置为当前连锁的对象卡（取对象）。
	local g=Duel.SelectTarget(tp,c13143275.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp,zone)
	-- 将本连锁的操作信息登记为“特殊召唤”分类，登记对象为选中的1只怪兽，用于其他卡片（如星尘龙等）对特殊召唤行为的检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：重新获取多连指区域，若目标区域仍存在且对象卡与效果关联，则将那只怪兽以表侧表示特殊召唤到多连指区域中。
function c13143275.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 在处理阶段重新获取当前被2只以上连接怪兽所指向的格子，以避免发动后区域状态变化导致错误。
	local zone=aux.GetMultiLinkedZone(tp)
	-- 取得发动②效果时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if zone~=0 and tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示（正面表示）特殊召唤到玩家自己的多连指区域，并完成特殊召唤的规则处理。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
