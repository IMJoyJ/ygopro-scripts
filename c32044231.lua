--RUM－マジカル・フォース
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只魔法师族·4阶的超量怪兽为对象才能发动。那只怪兽效果无效特殊召唤，把1只魔法师族·5阶的超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤，把这张卡作为那超量素材。
local s,id,o=GetID()
-- 创建效果，设置为发动时点，可以取对象，发动次数限制为1次
function s.initial_effect(c)
	-- ①：以自己墓地1只魔法师族·4阶的超量怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于检测墓地中的4阶魔法师族超量怪兽是否满足特殊召唤条件
function s.filter1(c,e,tp)
	return c:IsRank(4) and c:IsRace(RACE_SPELLCASTER) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检测是否存在满足条件的5阶魔法师族超量怪兽作为后续特殊召唤对象
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 过滤函数，用于检测额外卡组中的5阶魔法师族超量怪兽是否满足特殊召唤条件
function s.filter2(c,e,tp,mc)
	if c:GetOriginalCode()==6165656 and not mc:IsCode(48995978) then return false end
	return c:IsRank(5) and c:IsRace(RACE_SPELLCASTER) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c)
		-- 检测额外卡组中是否有足够的空间进行超量召唤
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 设置效果目标选择函数，用于选择墓地中的4阶魔法师族超量怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.filter1(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检测场上是否有足够的空间进行特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测是否满足作为超量素材的条件
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检测是否存在满足条件的墓地怪兽作为目标
		and Duel.IsExistingTarget(s.filter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为目标
	local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示将要特殊召唤2张卡（1张墓地怪兽+1张额外怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,tp,LOCATION_EXTRA)
end
-- 发动效果的处理函数，执行特殊召唤和叠放操作
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检测场上是否有足够的空间进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end
	-- 尝试特殊召唤目标怪兽
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 使目标怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使目标怪兽效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) and not Duel.IsPlayerAffectedByEffect(tp,59822133) then
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从额外卡组选择满足条件的5阶魔法师族超量怪兽
			local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
			local sc=g:GetFirst()
			if sc then
				sc:SetMaterial(Group.FromCards(tc))
				-- 将目标怪兽叠放到选中的额外怪兽上
				Duel.Overlay(sc,Group.FromCards(tc))
				-- 将选中的额外怪兽特殊召唤
				Duel.SpecialSummonStep(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
				sc:CompleteProcedure()
				if c:IsRelateToEffect(e) and c:IsCanOverlay() then
					c:CancelToGrave()
					-- 将此卡叠放到特殊召唤的怪兽上
					Duel.Overlay(sc,Group.FromCards(c))
				end
			end
		end
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
