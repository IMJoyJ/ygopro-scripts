--捕食植物コーディセップス
-- 效果：
-- ①：自己准备阶段把墓地的这张卡除外，以自己墓地2只4星以下的「捕食植物」怪兽为对象才能发动。那些怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不能通常召唤，不是融合怪兽不能特殊召唤。
function c7161742.initial_effect(c)
	-- ①：自己准备阶段把墓地的这张卡除外，以自己墓地2只4星以下的「捕食植物」怪兽为对象才能发动。那些怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不能通常召唤，不是融合怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7161742,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c7161742.spcon)
	-- 将墓地的这张卡除外作为发动代价
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c7161742.sptg)
	e1:SetOperation(c7161742.spop)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件函数
function c7161742.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 过滤自己墓地4星以下的「捕食植物」怪兽且能特殊召唤
function c7161742.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x10f3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果发动时的对象选择与可行性检测函数
function c7161742.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c7161742.filter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 判定自己场上的主要怪兽区域空位数是否大于1
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 判定自己墓地是否存在2只满足条件的怪兽可以作为对象
		and Duel.IsExistingTarget(c7161742.filter,tp,LOCATION_GRAVE,0,2,e:GetHandler(),e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地2只4星以下的「捕食植物」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c7161742.filter,tp,LOCATION_GRAVE,0,2,2,e:GetHandler(),e,tp)
	-- 设置特殊召唤2只怪兽的效果处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 定义效果处理函数
function c7161742.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上主要怪兽区域的空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取仍与该效果相关的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>0 and (g:GetCount()>0 or (g:GetCount()>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133))) then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		if g:GetCount()>ft then g=g:Select(tp,ft,ft,nil) end
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不能通常召唤，不是融合怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c7161742.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤融合怪兽以外怪兽的玩家效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- 注册不能通常召唤（表侧表示召唤）的玩家效果
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_MSET)
	-- 注册不能通常召唤（里侧表示盖放）的玩家效果
	Duel.RegisterEffect(e3,tp)
	-- 这个效果的发动后，直到回合结束时自己不能通常召唤
	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(63060238)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,0)
	e4:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能通常召唤的玩家效果
	Duel.RegisterEffect(e4,tp)
end
-- 限制只能特殊召唤融合怪兽
function c7161742.splimit(e,c)
	return not c:IsType(TYPE_FUSION)
end
