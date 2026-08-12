--罪鍵の法－シン・キー・ロウ
-- 效果：
-- 选择自己场上1只超量怪兽才能发动。把3只「阴影蜃景衍生物」（恶魔族·暗·1星·攻?/守0）特殊召唤。这衍生物的攻击力变成和选择的怪兽的攻击力相同。这衍生物不能直接攻击，不能为上级召唤以外而解放。选择的怪兽从场上离开时，这个效果特殊召唤的衍生物全部破坏。
function c67949763.initial_effect(c)
	-- 选择自己场上1只超量怪兽才能发动。把3只「阴影蜃景衍生物」（恶魔族·暗·1星·攻?/守0）特殊召唤。这衍生物的攻击力变成和选择的怪兽的攻击力相同。这衍生物不能直接攻击，不能为上级召唤以外而解放。选择的怪兽从场上离开时，这个效果特殊召唤的衍生物全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c67949763.target)
	e1:SetOperation(c67949763.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的超量怪兽，且玩家能够特殊召唤衍生物
function c67949763.filter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		-- 检查玩家是否能特殊召唤「阴影蜃景衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,67949764,0x87,TYPES_TOKEN_MONSTER,-2,0,1,RACE_FIEND,ATTRIBUTE_DARK)
end
-- 效果发动时的对象选择与可行性检测
function c67949763.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c67949763.filter(chkc,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上的怪兽区域空位数是否大于2
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		-- 检查自己场上是否存在符合条件的超量怪兽作为对象
		and Duel.IsExistingTarget(c67949763.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的超量怪兽作为对象
	Duel.SelectTarget(tp,c67949763.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置效果处理信息为产生3个衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,3,0,0)
	-- 设置效果处理信息为特殊召唤3只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,0,0)
end
-- 效果处理的执行函数
function c67949763.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 获取发动时选择的超量怪兽对象
	local tc=Duel.GetFirstTarget()
	-- 检查当前自己场上是否有3个以上的怪兽区域空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>2 then
		local rfid=tc:GetRealFieldID()
		local atk=0
		local cr=false
		if tc:IsFaceup() and tc:IsRelateToEffect(e) then
			atk=tc:GetAttack()
			cr=true
		end
		-- 检查此时是否仍能特殊召唤「阴影蜃景衍生物」，若不能则结束处理
		if not Duel.IsPlayerCanSpecialSummonMonster(tp,67949764,0x87,TYPES_TOKEN_MONSTER,-2,0,1,RACE_FIEND,ATTRIBUTE_DARK) then return end
		if cr then
			-- 选择的怪兽从场上离开时，这个效果特殊召唤的衍生物全部破坏。
			local de=Effect.CreateEffect(e:GetHandler())
			de:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			de:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			de:SetCode(EVENT_LEAVE_FIELD)
			de:SetOperation(c67949763.desop)
			de:SetLabel(rfid)
			tc:RegisterEffect(de,true)
		end
		for i=1,3 do
			-- 创建「阴影蜃景衍生物」的卡片数据
			local token=Duel.CreateToken(tp,67949764)
			-- 尝试以表侧表示特殊召唤该衍生物（分步特招）
			if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
				-- 这衍生物不能直接攻击
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				token:RegisterEffect(e1)
				-- 不能为上级召唤以外而解放
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
				e2:SetValue(1)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				token:RegisterEffect(e2)
				-- 这衍生物的攻击力变成和选择的怪兽的攻击力相同。
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_SET_ATTACK)
				e3:SetValue(atk)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD)
				token:RegisterEffect(e3)
			end
			if cr then
				token:RegisterFlagEffect(67949764,RESET_EVENT+RESETS_STANDARD,0,0,rfid)
				tc:CreateRelation(token,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			end
		end
		-- 完成所有分步特殊召唤的处理
		Duel.SpecialSummonComplete()
	end
end
-- 过滤出带有与离场超量怪兽相同关系标识的衍生物
function c67949763.desfilter(c,rfid)
	return c:GetFlagEffectLabel(67949764)==rfid
end
-- 超量怪兽离场时，破坏对应衍生物的效果处理函数
function c67949763.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有与离场超量怪兽相关联的衍生物
	local g=Duel.GetMatchingGroup(c67949763.desfilter,tp,LOCATION_MZONE,0,nil,e:GetLabel())
	-- 因效果破坏这些衍生物
	Duel.Destroy(g,REASON_EFFECT)
	e:Reset()
end
