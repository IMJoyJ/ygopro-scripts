--バスター・モード
-- 效果：
-- ①：把自己场上1只同调怪兽解放才能发动。包含那只怪兽卡名的1只「/爆裂体」怪兽从卡组攻击表示特殊召唤。
function c80280737.initial_effect(c)
	-- ①：把自己场上1只同调怪兽解放才能发动。包含那只怪兽卡名的1只「/爆裂体」怪兽从卡组攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c80280737.target)
	e1:SetOperation(c80280737.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件1：用于检测场上可解放的、且卡组存在对应「/爆裂体」怪兽的同调怪兽
function c80280737.filter1(c,e,tp)
	-- 必须是同调怪兽、可以被解放，且解放该怪兽后能腾出可用的怪兽区域
	return c:IsType(TYPE_SYNCHRO) and c:IsReleasable() and Duel.GetMZoneCount(tp,c)>0
		-- 并且卡组中存在与该同调怪兽卡名对应的「/爆裂体」怪兽
		and Duel.IsExistingMatchingCard(c80280737.filter2,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
-- 过滤条件2：卡组中属于「/爆裂体」系列、对应解放怪兽卡名、且可以攻击表示特殊召唤的怪兽
function c80280737.filter2(c,e,tp,tcode)
	return c:IsSetCard(0x104f) and c.assault_name==tcode and c:IsCanBeSpecialSummoned(e,0,tp,false,true,POS_FACEUP_ATTACK)
end
-- 效果发动的目标与代价处理：选择并解放1只同调怪兽，并声明特殊召唤效果
function c80280737.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上满足过滤条件1的可解放怪兽组
	local g=Duel.GetReleaseGroup(tp,false):Filter(c80280737.filter1,nil,e,tp)
	-- 检查是否适用特定卡片（如「爆裂狙击兵」）允许从额外卡组解放同调怪兽的代替效果
	if Duel.GetFlagEffect(tp,91002901)>Duel.GetFlagEffect(tp,80280737) then
		-- 将额外卡组中满足条件的同调怪兽合并到可选解放的怪兽组中
		g:Merge(Duel.GetMatchingGroup(c80280737.filter1,tp,LOCATION_EXTRA,0,nil,e,tp))
	end
	if chk==0 then return e:IsCostChecked() and g:GetCount()>0 end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local rg=g:Select(tp,1,1,nil)
	if rg:IsExists(Card.IsLocation,1,nil,LOCATION_EXTRA) then
		-- 向双方玩家展示代替解放效果的卡片（如「爆裂狙击兵」）
		Duel.Hint(HINT_CARD,0,91002901)
		-- 为玩家注册已使用代替解放效果的标记，持续到回合结束
		Duel.RegisterFlagEffect(tp,80280737,RESET_PHASE+PHASE_END,0,1)
	end
	-- 消耗代替解放效果的使用次数
	aux.UseExtraReleaseCount(rg,tp)
	e:SetLabel(rg:GetFirst():GetCode())
	-- 解放选中的怪兽作为发动的代价
	Duel.Release(rg,REASON_COST)
	-- 设置当前处理的连锁操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组将对应的「/爆裂体」怪兽攻击表示特殊召唤
function c80280737.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位，若无则无法特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只与被解放怪兽卡名对应的「/爆裂体」怪兽
	local tc=Duel.SelectMatchingCard(tp,c80280737.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel()):GetFirst()
	-- 若成功选择，则将该怪兽以表侧攻击表示特殊召唤（无视苏生限制）
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,true,POS_FACEUP_ATTACK)>0 then
		tc:CompleteProcedure()
	end
end
