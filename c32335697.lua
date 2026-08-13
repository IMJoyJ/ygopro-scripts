--ホーンテッド・アンデット
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从自己或者对方的墓地选1只不死族怪兽除外，把持有和那个等级相同等级的2只「祟灵衍生物」（不死族·暗·攻/守0）在自己场上特殊召唤。
-- ②：这张卡在墓地存在的场合才能发动。选除外的1只自己的不死族怪兽回到卡组，这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
function c32335697.initial_effect(c)
	-- ①：从自己或者对方的墓地选1只不死族怪兽除外，把持有和那个等级相同等级的2只「祟灵衍生物」（不死族·暗·攻/守0）在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32335697,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,32335697)
	e1:SetTarget(c32335697.target)
	e1:SetOperation(c32335697.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合才能发动。选除外的1只自己的不死族怪兽回到卡组，这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32335697,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,32335697)
	e2:SetTarget(c32335697.settg)
	e2:SetOperation(c32335697.setop)
	c:RegisterEffect(e2)
end
-- 检索/筛选可除外的墓地不死族怪兽：要求是不死族、等级1以上、可以除外，且当前玩家能以其等级在己方场上特殊召唤「祟灵衍生物」。
function c32335697.rmfilter(c,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsLevelAbove(1) and c:IsAbleToRemove()
		-- 判定当前玩家是否能够特殊召唤卡号32335698的衍生物（不死族·暗·攻/守0，等级等于被选怪兽等级）到己方场上，以确保能成功特招。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,32335698,nil,TYPES_TOKEN_MONSTER,0,0,c:GetLevel(),RACE_ZOMBIE,ATTRIBUTE_DARK)
end
-- ①效果的发动条件：己方主要怪兽区空格大于1，双方墓地存在满足rmfilter的1只不死族怪兽，且己方不受【青眼精灵龙】的“不能同时特殊召唤2只以上怪兽”效果影响。
function c32335697.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区是否有至少2个可用空格（用于特殊召唤2只衍生物）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查双方墓地是否存在至少1只满足rmfilter条件的不死族怪兽（可以作为①的除外对象）。
		and Duel.IsExistingMatchingCard(c32335697.rmfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,tp)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133) end
	-- 设置操作信息：本连锁可能从墓地除外1只怪兽（对象在效果处理时选择，持有者不限，位置为墓地）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_ALL,LOCATION_GRAVE)
	-- 设置操作信息：本连锁将特殊召唤2只怪兽（衍生物），数量为2，持有者/位置待定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
	-- 设置操作信息：本连锁涉及生成2只衍生物（CATEGORY_TOKEN），数量为2。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
end
-- ①的效果处理：若空格不足或受【青眼精灵龙】限制则直接终止；否则选择1只墓地不死族怪兽除外，成功后生成2只「祟灵衍生物」并使其等级等于除外怪兽的等级，再特殊召唤到己方场上。
function c32335697.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 向玩家显示选择提示，要求选择要除外的卡（HINTMSG_REMOVE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从双方墓地中选出1只满足rmfilter条件的不死族怪兽，并取得该卡（只选1张）。
	local tc=Duel.SelectMatchingCard(tp,c32335697.rmfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,tp):GetFirst()
	-- 判断选择的怪兽是否成功除外且现在位于除外区；只有成功除外才继续处理特招衍生物。
	if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_REMOVED)
		-- 再次确认当前玩家仍能特殊召唤与除外怪兽等级相同的「祟灵衍生物」（防止连锁处理中条件发生变化）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,32335698,nil,TYPES_TOKEN_MONSTER,0,0,tc:GetLevel(),RACE_ZOMBIE,ATTRIBUTE_DARK) then
		for i=1,2 do
			-- 在玩家tp场上生成1只卡号32335698的「祟灵衍生物」衍生物。
			local token=Duel.CreateToken(tp,32335698)
			-- 持有和那个等级相同等级的2只「祟灵衍生物」
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(tc:GetLevel())
			token:RegisterEffect(e1)
			-- 将衍生物以表侧表示特殊召唤到己方场上（不检查召唤条件/苏生限制）。
			Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 定义②的回收对象过滤条件：除外区表侧表示的不死族怪兽，且可以返回卡组。
function c32335697.setfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsAbleToDeck()
end
-- ②的发动条件：自身在墓地且可以被盖放，并且除外区存在满足setfilter的己方不死族怪兽。
function c32335697.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable()
		-- 检查除外区是否存在至少1张自己的不死族表侧表示且能够返回卡组的卡。
		and Duel.IsExistingMatchingCard(c32335697.setfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 设置操作信息：本连锁涉及这张卡从墓地离开（盖放），供相关效果检测（如王家长眠之谷）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②的效果处理：选择1张除外区己方不死族表侧怪兽返回卡组洗牌；若成功且自身仍与效果关联，则把自身盖放到己方魔陷区，并附加离场时除外的效果。
function c32335697.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向玩家显示选择提示，要求选择要返回卡组的卡（HINTMSG_TODECK）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己除外区选出1张满足setfilter条件的表侧不死族怪兽。
	local g=Duel.SelectMatchingCard(tp,c32335697.setfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		-- 显示所选卡片被选为对象的动画，并记录这些卡被选为对象。
		Duel.HintSelection(g)
		-- 将选中的怪兽返回持有者卡组并洗牌；若返回成功、自身仍与效果关联且能够盖放，则将自身盖放到己方场上。
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and c:IsRelateToEffect(e) and Duel.SSet(tp,c)~=0 then
			-- 这个效果盖放的这张卡从场上离开的场合除外。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			c:RegisterEffect(e1)
		end
	end
end
