--RUM－マジカル・フォース
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只魔法师族·4阶的超量怪兽为对象才能发动。那只怪兽效果无效特殊召唤，把1只魔法师族·5阶的超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤，把这张卡作为那超量素材。
local s,id,o=GetID()
-- 注册这张卡的发动效果：效果分类为特殊召唤，类型为魔法卡发动，自由时点可发动，取对象，提示在结束阶段使用，并设置同名卡1回合只能发动1张的次数限制
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
-- 对象过滤函数：检查该卡是否为4阶的魔法师族超量怪兽、能否被这个效果特殊召唤，且额外卡组存在满足条件的升阶目标怪兽
function s.filter1(c,e,tp)
	return c:IsRank(4) and c:IsRace(RACE_SPELLCASTER) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 额外检查：额外卡组中需至少存在1只满足filter2条件、能在该怪兽上面重叠特殊召唤的5阶超量怪兽
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 升阶目标过滤函数：排除「重铠装-黑鳍条枪兵」（6165656）在非「冀望皇 巴利安」（48995978）上重叠的情况，要求该卡为5阶的魔法师族超量怪兽、对象怪兽能作为其超量素材，且能以超量召唤方式特殊召唤并有可用的怪兽区空格
function s.filter2(c,e,tp,mc)
	if c:GetOriginalCode()==6165656 and not mc:IsCode(48995978) then return false end
	return c:IsRank(5) and c:IsRace(RACE_SPELLCASTER) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c)
		-- 检查该怪兽能否以超量召唤方式特殊召唤，且让对象怪兽离场后额外卡组的该怪兽有可用的出场空格
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 对象函数：在成为连锁对象时检查对象是否为自己墓地满足filter1的卡；在能否发动的检测中，确认玩家能特殊召唤2次、主要怪兽区有空格、没有「必须作为超量素材」的限制，且墓地存在可作为对象的满足条件的怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.filter1(chkc,e,tp) end
	-- 在能否发动的检测中，先确认玩家还能进行2次特殊召唤（墓地怪兽和升阶怪兽各1次）
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 确认自己主要怪兽区至少有1个空格可供特殊召唤使用
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认没有受到「必须作为超量素材」类效果的影响而妨碍本次升阶处理
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 确认自己墓地存在1只满足filter1条件且能成为这个效果对象的魔法师族·4阶超量怪兽
		and Duel.IsExistingTarget(s.filter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送「请选择要特殊召唤的卡」的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足条件的魔法师族·4阶超量怪兽作为这个效果的对象
	local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：这个连锁将特殊召唤2张卡（对象怪兽和额外卡组的升阶怪兽），供星尘龙等效果的发动检测使用
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,tp,LOCATION_EXTRA)
end
-- 效果处理：确认主要怪兽区有空格后取得对象怪兽，检查其仍与连锁关联且不受效果免疫则将其效果无效化特殊召唤，再从额外卡组选1只5阶魔法师族超量怪兽在其上面重叠当作超量召唤特殊召唤，最后把这张卡叠放为其超量素材
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时若自己主要怪兽区没有空格则中止处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取得这个连锁的对象卡（墓地的那只4阶超量怪兽）
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() or tc:IsImmuneToEffect(e) then return end
	-- 将对象怪兽以表侧表示特殊召唤（分步特殊召唤，成功才继续后续处理）
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 那只怪兽效果无效特殊召唤
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那只怪兽效果无效特殊召唤
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 完成本次分步特殊召唤，使对象怪兽的特殊召唤正式成立
		Duel.SpecialSummonComplete()
		-- 若对象怪兽因「必须作为超量素材」类限制无法成为超量素材，则中止后续的升阶处理
		if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
		-- 向玩家发送「请选择要特殊召唤的卡」的选择提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从额外卡组选择1只满足filter2条件的魔法师族·5阶超量怪兽
		local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
		local sc=g:GetFirst()
		if sc then
			-- 中断当前效果处理，使之后的升阶特殊召唤视为不同时处理（避免同时处理的时点问题）
			Duel.BreakEffect()
			sc:SetMaterial(Group.FromCards(tc))
			-- 把对象怪兽作为超量素材叠放在升阶怪兽下面
			Duel.Overlay(sc,Group.FromCards(tc))
			-- 将升阶怪兽以超量召唤方式表侧表示特殊召唤（分步特殊召唤）
			Duel.SpecialSummonStep(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
			if c:IsRelateToEffect(e) and c:IsCanOverlay() then
				c:CancelToGrave()
				-- 把这张卡（升阶魔法-魔法之力）叠放为升阶怪兽的超量素材
				Duel.Overlay(sc,Group.FromCards(c))
			end
			-- 完成分步特殊召唤，使升阶怪兽的超量召唤正式成立
			Duel.SpecialSummonComplete()
		end
	end
end
