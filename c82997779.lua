--デーモンの簒奪
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●从自己的卡组·墓地把1张「恶魔」陷阱卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
-- ●等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从自己的手卡·额外卡组（表侧）把1只「恶魔」仪式怪兽仪式召唤。
local s,id,o=GetID()
-- 注册卡片发动时的效果：1回合只能发动1张，包含盖放魔陷或特殊召唤的效果，自由时点发动
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：卡组·墓地中可盖放的「恶魔」陷阱卡
function s.setfilter(c)
	return c:IsSetCard(0x45) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 过滤条件：手卡·额外卡组（表侧）的「恶魔」仪式怪兽
function s.ritual_filter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_RITUAL) and c:IsSetCard(0x45)
end
-- 效果发动时的目标选择与可行性检查：判断两个可选效果是否满足发动条件，并让玩家选择其中一个发动，根据选择更新效果分类和操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上可用的魔法与陷阱区域数量
	local ct=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ct=ct-1 end
	-- 检查是否满足效果1的发动条件：魔陷区有空位，且卡组·墓地存在可盖放的「恶魔」陷阱卡
	local b1=ct>0 and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	-- 获取玩家当前可用于仪式召唤的素材怪兽组
	local mg=Duel.GetRitualMaterial(tp)
	-- 检查是否满足效果2的发动条件：手卡·额外卡组（表侧）存在可进行仪式召唤的「恶魔」仪式怪兽
	local b2=Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil,s.rfilter,e,tp,mg,nil,Card.GetLevel,"Greater")
	if chk==0 then return b1 or b2 end
	-- 让玩家选择要发动的效果分支（盖放陷阱卡或进行仪式召唤）
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,0),1},  --"盖放"
		{b2,aux.Stringid(id,1),2})  --"仪式召唤"
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SSET)
		end
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		end
		-- 设置操作信息：从手卡·额外卡组特殊召唤1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_EXTRA)
	end
end
-- 过滤条件：用于仪式召唤的「恶魔」仪式怪兽
function s.rfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x45)
end
-- 效果处理：根据玩家的选择，执行盖放「恶魔」陷阱卡（并赋予当回合发动效果）或进行「恶魔」仪式怪兽的仪式召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 提示玩家选择要盖放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从卡组·墓地选择1张满足条件的「恶魔」陷阱卡（受王家长眠之谷影响）
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		local tc=g:GetFirst()
		-- 若成功将选中的卡在自己场上盖放
		if tc and Duel.SSet(tp,tc)~=0 then
			-- 这个效果盖放的卡在盖放的回合也能发动。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,2))  --"适用「恶魔的篡夺」的效果来发动"
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	elseif e:GetLabel()==2 then
		::cancel::
		-- 重新获取可用于仪式召唤的素材怪兽组
		local mg=Duel.GetRitualMaterial(tp)
		-- 提示玩家选择要特殊召唤的仪式怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡·额外卡组（表侧）选择1只可进行仪式召唤的「恶魔」仪式怪兽
		local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(aux.RitualUltimateFilter),tp,LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil,s.rfilter,e,tp,mg,nil,Card.GetLevel,"Greater")
		local tc=tg:GetFirst()
		if tc then
			mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
			if tc.mat_filter then
				mg=mg:Filter(tc.mat_filter,tc,tp)
			else
				mg:RemoveCard(tc)
			end
			-- 提示玩家选择要解放的素材怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
			-- 设置仪式召唤的额外等级检查，要求解放怪兽的等级合计在仪式怪兽的等级以上
			aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
			-- 让玩家选择用于解放的仪式素材怪兽组
			local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
			-- 重置全局附加检查函数
			aux.GCheckAdditional=nil
			if not mat then goto cancel end
			tc:SetMaterial(mat)
			-- 解放选定的仪式素材怪兽
			Duel.ReleaseRitualMaterial(mat)
			-- 中断当前效果处理，使后续的特殊召唤不与解放同时处理
			Duel.BreakEffect()
			-- 将选中的仪式怪兽以仪式召唤的方式特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
			tc:CompleteProcedure()
		end
	end
end
