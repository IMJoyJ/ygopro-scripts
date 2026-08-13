--ヴェンデット・リユニオン
-- 效果：
-- ①：把仪式召唤的手卡1只「复仇死者」仪式怪兽给对方观看。等级合计直到变成和给人观看的仪式怪兽的等级相同为止，选除外的自己的「复仇死者」怪兽任意数量里侧守备表示特殊召唤（同名卡最多1张）。那之后，那些里侧守备表示怪兽全部解放从手卡把那只仪式怪兽仪式召唤。
function c2266498.initial_effect(c)
	-- ①：把仪式召唤的手卡1只「复仇死者」仪式怪兽给对方观看。等级合计直到变成和给人观看的仪式怪兽的等级相同为止，选除外的自己的「复仇死者」怪兽任意数量里侧守备表示特殊召唤（同名卡最多1张）。那之后，那些里侧守备表示怪兽全部解放从手卡把那只仪式怪兽仪式召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c2266498.target)
	e1:SetOperation(c2266498.activate)
	c:RegisterEffect(e1)
end
-- 筛选手卡中满足发动条件的「复仇死者」仪式怪兽：必须是仪式怪兽（类型含0x81）、属于「复仇死者」系列、未公开，并且能够以仪式召唤的方式特殊召唤。若该怪兽有素材过滤器则后续会套用。
function c2266498.cfilter(c,e,tp,m,ft)
	if bit.band(c:GetType(),0x81)~=0x81 or not c:IsSetCard(0x106) or c:IsPublic()
		or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	if c.mat_filter then
		m=m:Filter(c.mat_filter,nil,tp)
	end
	-- 设置额外素材合法性检查为“等级合计必须恰好等于该仪式怪兽等级”，使后续的素材组合选择必须满足这一精等条件。
	aux.GCheckAdditional=aux.RitualCheckAdditional(c,c:GetLevel(),"Equal")
	local res=m:CheckSubGroup(c2266498.fselect,1,math.min(c:GetLevel(),ft),c)
	-- 清除之前设置的额外素材合法性检查，避免影响其他卡片的效果。
	aux.GCheckAdditional=nil
	return res
end
-- 定义素材选择完成判定：当前选中的素材组必须卡名互不相同（同名卡最多1张），且等级合计与仪式怪兽等级完全相等。
function c2266498.fselect(g,mc)
	-- 判断当前素材组卡名互不相同，且等级合计等于仪式怪兽等级（使用仪式等级计算）。
	return aux.dncheck(g) and g:CheckWithSumEqual(Card.GetRitualLevel,mc:GetLevel(),g:GetCount(),g:GetCount(),mc)
end
-- 筛选除外区可作为素材的自己的「复仇死者」怪兽：表侧表示、属于系列、可以被解放，且能以里侧守备表示特殊召唤。
function c2266498.filter(c,e,tp)
	-- 要求除外区的候选素材是表侧表示、属于「复仇死者」系列，并且当前玩家可以解放它（为后续解放做预检）。
	return c:IsFaceup() and c:IsSetCard(0x106) and Duel.IsPlayerCanRelease(tp,c,REASON_EFFECT)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果发动的目标选择阶段：预检场地空格、特殊召唤次数、可用的除外区素材以及手卡中的仪式怪兽，全部满足才可发动，并登记操作信息。
function c2266498.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己主要怪兽区的可用空格数。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 没有可用空格，或本回合剩余的特殊召唤次数不足2次（需先特召素材再仪式召唤）时，不能发动。
		if ft<=0 or not Duel.IsPlayerCanSpecialSummonCount(tp,2) then return false end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 获取除外区中可作为素材的自己的「复仇死者」怪兽集合（表侧、可解放、可里侧守备特召）。
		local mg=Duel.GetMatchingGroup(c2266498.filter,tp,LOCATION_REMOVED,0,nil,e,tp)
		-- 检查手卡中是否存在满足条件的「复仇死者」仪式怪兽，且能配合素材完成后续仪式召唤。
		return Duel.IsExistingMatchingCard(c2266498.cfilter,tp,LOCATION_HAND,0,1,nil,e,tp,mg,ft)
	end
	-- 登记操作信息：该效果涉及特殊召唤，对象涉及手卡和除外区的卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_REMOVED)
end
-- 效果处理阶段：选择并展示手卡中的仪式怪兽，从除外区选择素材里侧守备特殊召唤，解放素材后仪式召唤该怪兽。
function c2266498.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时获取自己主要怪兽区的可用空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 若可用空格为0或无法再进行2次特殊召唤，则效果处理失败终止。
	if ft<=0 or not Duel.IsPlayerCanSpecialSummonCount(tp,2) then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 处理时重新获取除外区可选素材集合。
	local mg=Duel.GetMatchingGroup(c2266498.filter,tp,LOCATION_REMOVED,0,nil,e,tp)
	-- 弹出选择提示，让玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1张符合条件的「复仇死者」仪式怪兽，作为后续仪式召唤的对象。
	local tg=Duel.SelectMatchingCard(tp,c2266498.cfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,mg,ft)
	if tg:GetCount()>0 then
		-- 向对方玩家展示所选的手卡仪式怪兽，对应效果中“给对方观看”。
		Duel.ConfirmCards(1-tp,tg)
		local tc=tg:GetFirst()
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,nil,tp)
		end
		-- 弹出选择提示，让玩家从除外区选择要里侧守备表示特殊召唤的素材怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 为当前展示的仪式怪兽设置“等级合计必须恰好相等”的额外合法性检查，确保所选素材等级之和正好等于该怪兽等级。
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Equal")
		local sg=mg:SelectSubGroup(tp,c2266498.fselect,false,1,math.min(tc:GetLevel(),ft),tc)
		-- 清除该额外合法性检查。
		aux.GCheckAdditional=nil
		if not sg or sg:GetCount()==0 then return end
		-- 将选中的素材全部里侧守备表示特殊召唤；只有全部特殊召唤成功，才继续执行后续解放与仪式召唤。
		if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)==sg:GetCount() then
			-- 中断当前效果链，使此后的处理与前一步操作不在同一时点，正确区分“特殊召唤素材”和“仪式召唤”。
			Duel.BreakEffect()
			-- 取得刚刚特殊召唤成功的那组素材怪兽（实际操作的卡）。
			local og=Duel.GetOperatedGroup()
			-- 向对方展示这些被特殊召唤的里侧守备表示怪兽。
			Duel.ConfirmCards(1-tp,og)
			tc:SetMaterial(og)
			-- 将素材怪兽全部解放，作为仪式召唤的素材解放（原因包含效果、仪式召唤、素材）。
			Duel.Release(og,REASON_EFFECT+REASON_RITUAL+REASON_MATERIAL)
			-- 再次中断效果，使解放素材与随后的仪式召唤正确分步处理。
			Duel.BreakEffect()
			-- 从手卡以仪式召唤方式将展示的仪式怪兽表侧攻击表示特殊召唤到场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
			tc:CompleteProcedure()
		end
	end
end
