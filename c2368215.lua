--魔界劇団－ハイパー・ディレクター
-- 效果：
-- 「魔界剧团」灵摆怪兽1只
-- 这个卡名的效果1回合只能使用1次。
-- ①：以自己的灵摆区域1张卡为对象才能发动。那张卡特殊召唤。那之后，从卡组的怪兽以及自己的额外卡组的表侧表示的灵摆怪兽之中选和特殊召唤的怪兽卡名不同的1只「魔界剧团」灵摆怪兽在自己的灵摆区域放置。这个效果的发动后，直到回合结束时自己不是「魔界剧团」怪兽不能召唤·特殊召唤。
function c2368215.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：素材为1只满足mfilter的怪兽，即「魔界剧团」灵摆怪兽1只。
	aux.AddLinkProcedure(c,c2368215.mfilter,1,1)
	-- 这个卡名的效果1回合只能使用1次。①：以自己的灵摆区域1张卡为对象才能发动。那张卡特殊召唤。那之后，从卡组的怪兽以及自己的额外卡组的表侧表示的灵摆怪兽之中选和特殊召唤的怪兽卡名不同的1只「魔界剧团」灵摆怪兽在自己的灵摆区域放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2368215,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,2368215)
	e1:SetTarget(c2368215.sptg)
	e1:SetOperation(c2368215.spop)
	c:RegisterEffect(e1)
end
-- 该过滤函数用于连接素材判断：素材必须是当作「魔界剧团」字段使用、且作为连接素材时为灵摆族的怪兽。
function c2368215.mfilter(c)
	return c:IsLinkSetCard(0x10ec) and c:IsLinkType(TYPE_PENDULUM)
end
-- spfilter 判断目标卡能否被特殊召唤，且必须存在至少1张与它卡名不同的「魔界剧团」灵摆怪兽可被检索放置在灵摆区。
function c2368215.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 该行在 spfilter 中检查卡组和额外卡组是否存在至少1张满足 stfilter 的「魔界剧团」灵摆怪兽，且其卡名与目标怪兽不同。
		and Duel.IsExistingMatchingCard(c2368215.stfilter,tp,LOCATION_EXTRA+LOCATION_DECK,0,1,nil,c:GetCode())
end
-- stfilter 筛选可放置到灵摆区的卡：来自额外卡组表侧表示或卡组的灵摆怪兽，属于「魔界剧团」字段，卡名不与指定卡相同，且不在禁止状态。
function c2368215.stfilter(c,code)
	return (c:IsFaceup() or c:IsLocation(LOCATION_DECK)) and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x10ec) and not c:IsCode(code) and not c:IsForbidden()
end
-- sptg 是效果的发动条件与对象选择函数：先校验对象是否在己方灵摆区且可被特殊召唤，再检查主要怪兽区有空位且存在合法目标。
function c2368215.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) and c2368215.spfilter(chkc,e,tp) end
	-- 发动前检查己方主要怪兽区是否有至少1个可用空格，以确保特殊召唤能够进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动前检查己方灵摆区是否有至少1张满足 spfilter 的卡可以作为效果对象。
		and Duel.IsExistingTarget(c2368215.spfilter,tp,LOCATION_PZONE,0,1,nil,e,tp) end
	-- 给玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己灵摆区选择1张满足 spfilter 的卡，并将它登记为本连锁的效果对象。
	local g=Duel.SelectTarget(tp,c2368215.spfilter,tp,LOCATION_PZONE,0,1,1,nil,e,tp)
	-- 登记操作信息：本次效果将进行1只怪兽的特殊召唤，目标为已选对象，供连锁判定相关效果使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- spop 是效果处理函数：特殊召唤对象怪兽，成功后从卡组/额外卡组选1张符合条件的「魔界剧团」灵摆怪兽表侧放置到自己的灵摆区。
function c2368215.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果对象（灵摆区被选中的卡）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与效果关联并尝试将其特殊召唤；若特殊召唤成功则继续执行后续放置。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 确认自己灵摆区至少有一个空格可用，用于放置后续选出的灵摆怪兽。
		and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then
		local code=tc:GetCode()
		-- 从卡组和额外卡组中选择1张满足 stfilter 且卡名与特殊召唤的怪兽不同的「魔界剧团」灵摆怪兽。
		local g=Duel.SelectMatchingCard(tp,c2368215.stfilter,tp,LOCATION_EXTRA+LOCATION_DECK,0,1,1,nil,code)
		if g:GetCount()>0 then
			-- 中断当前效果链，使之后的灵摆区放置与之前的特殊召唤分为不同时点处理，避免错过时点。
			Duel.BreakEffect()
			-- 将选出的灵摆怪兽以表侧表示移动到自己的灵摆区，并立即适用其效果。
			Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是「魔界剧团」怪兽不能召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c2368215.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能召唤非「魔界剧团」怪兽”的永续效果注册给当前回合玩家，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	-- 将“不能特殊召唤非「魔界剧团」怪兽”的永续效果注册给当前回合玩家，持续到回合结束。
	Duel.RegisterEffect(e2,tp)
end
-- 自肃判定函数：若卡片不是「魔界剧团」字段则返回 true，从而被上述召唤·特殊召唤禁止效果限制。
function c2368215.splimit(e,c)
	return not c:IsSetCard(0x10ec)
end
