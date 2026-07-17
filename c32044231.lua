--RUM－マジカル・フォース
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只魔法师族·4阶的超量怪兽为对象才能发动。那只怪兽效果无效特殊召唤，把1只魔法师族·5阶的超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤，把这张卡作为那超量素材。
local s,id,o=GetID()
-- 注册这张魔法卡的发动效果：效果分类为特殊召唤、类型为魔陷发动、自由时点发动、取对象效果、提示时点为结束阶段、同名卡1回合只能发动1张（发动被无效不计数），并设定目标函数与效果处理函数
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己墓地1只魔法师族·4阶的超量怪兽为对象才能发动。
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
-- 对象过滤函数filter1：检查卡片是否为魔法师族·4阶的超量怪兽、能否被这个效果特殊召唤，并且额外卡组中存在可在其上面重叠特殊召唤的5阶超量怪兽
function s.filter1(c,e,tp)
	return c:IsRank(4) and c:IsRace(RACE_SPELLCASTER) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 并检查额外卡组是否存在至少1只满足filter2条件、可在该对象怪兽上面重叠特殊召唤的5阶超量怪兽
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 升阶目标过滤函数filter2：检查额外卡组的卡片是否为魔法师族·5阶的超量怪兽、对象怪兽能否作为它的超量素材（另含特例：原卡号6165656的怪兽只能重叠在卡号48995978的怪兽上面）
function s.filter2(c,e,tp,mc)
	if c:GetOriginalCode()==6165656 and not mc:IsCode(48995978) then return false end
	return c:IsRank(5) and c:IsRace(RACE_SPELLCASTER) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c)
		-- 并检查该5阶超量怪兽能否被当作超量召唤特殊召唤，以及让对象怪兽离场后把额外卡组怪兽特殊召唤所需的怪兽区空位是否存在
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 目标函数：连锁对象合法性检查时要求对象是自己墓地满足filter1条件的怪兽；发动条件检查则依次确认能否特殊召唤2次、怪兽区有无空位、素材限制及可选对象的存在
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.filter1(chkc,e,tp) end
	-- 检查玩家能否再进行2次特殊召唤（对象怪兽与升阶的5阶超量怪兽各1次）
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检查自己主要怪兽区是否有可用的空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否存在受「必须作为超量素材」效果影响的卡（存在则相关卡不能被用于正规处理）
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查自己墓地是否存在至少1只可以成为这个效果对象的、满足filter1条件的4阶魔法师族超量怪兽
		and Duel.IsExistingTarget(s.filter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送「请选择要特殊召唤的卡」的选择提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足条件的4阶魔法师族超量怪兽作为这个效果的对象
	local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次连锁确定要特殊召唤的卡为作为对象的怪兽及额外卡组的怪兽共2只，供星尘龙等发动检测使用
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,tp,LOCATION_EXTRA)
end
-- 效果处理函数：取回这张卡与对象怪兽，把对象怪兽效果无效特殊召唤，再从额外卡组选1只5阶魔法师族超量怪兽在其上面重叠当作超量召唤特殊召唤，最后把这张卡作为那超量素材
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若效果处理时自己主要怪兽区没有空格，则不再处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取得当前连锁的对象卡（作为对象的墓地4阶超量怪兽）
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() or tc:IsImmuneToEffect(e) then return end
	-- 将对象怪兽以表侧表示分步特殊召唤到自己场上（分步特殊召唤流程的第一步，成功才继续）
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 那只怪兽效果无效特殊召唤。（给予对象怪兽无效化效果）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那只怪兽效果无效特殊召唤。（使对象怪兽发动的效果无效）
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 完成对象怪兽的分步特殊召唤流程
		Duel.SpecialSummonComplete()
		-- 若对象怪兽受「必须作为超量素材」效果影响，则不再继续处理后续的重叠超量召唤
		if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
		-- 向玩家发送「请选择要特殊召唤的卡」的选择提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从额外卡组选择1只满足filter2条件的5阶魔法师族超量怪兽
		local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
		local sc=g:GetFirst()
		if sc then
			-- 中断当前效果处理，使之后5阶超量怪兽的特殊召唤与之前的处理视为不同时处理（会造成错时点）
			Duel.BreakEffect()
			sc:SetMaterial(Group.FromCards(tc))
			-- 把对象怪兽作为超量素材叠放在那只5阶超量怪兽的下面
			Duel.Overlay(sc,Group.FromCards(tc))
			-- 将那只5阶超量怪兽以超量召唤方式表侧表示分步特殊召唤
			Duel.SpecialSummonStep(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
			if c:IsRelateToEffect(e) and c:IsCanOverlay() then
				c:CancelToGrave()
				-- 把这张卡（升阶魔法-魔法之力）作为那超量怪兽的超量素材叠放在下面
				Duel.Overlay(sc,Group.FromCards(c))
			end
			-- 完成5阶超量怪兽的分步特殊召唤流程
			Duel.SpecialSummonComplete()
		end
	end
end
