--逢魔ノ妖刀－不知火
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把这张卡解放，从「逢魔之妖刀-不知火」以外的除外的自己怪兽之中以包含「不知火」怪兽的2只不死族怪兽为对象才能发动。那些怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这个效果的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
function c79783880.initial_effect(c)
	-- ①：把这张卡解放，从「逢魔之妖刀-不知火」以外的除外的自己怪兽之中以包含「不知火」怪兽的2只不死族怪兽为对象才能发动。那些怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这个效果的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79783880,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,79783880)
	e1:SetCost(c79783880.spcost)
	e1:SetTarget(c79783880.sptg)
	e1:SetOperation(c79783880.spop)
	c:RegisterEffect(e1)
end
-- 定义发动代价函数：检查自身是否可以解放，并将其解放
function c79783880.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身解放作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤除外区中满足条件的第1只怪兽：表侧表示的不死族「不知火」怪兽（非同名卡），且能守备表示特殊召唤，并且除外区还存在另一只可特召的不死族怪兽
function c79783880.spfilter1(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsSetCard(0xd9) and not c:IsCode(79783880) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 检查除外区是否存在另一只（除自身外）可以特殊召唤的不死族怪兽
		and Duel.IsExistingTarget(c79783880.spfilter2,tp,LOCATION_REMOVED,0,1,c,e,tp)
end
-- 过滤除外区中满足条件的第2只怪兽：表侧表示的不死族怪兽（非同名卡），且能守备表示特殊召唤
function c79783880.spfilter2(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and not c:IsCode(79783880) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 定义效果发动时的对象选择与检测函数：检查怪兽区域空位、精灵龙限制，并选择2只目标怪兽
function c79783880.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查在解放自身后，自己场上是否有2个及以上的空怪兽区域
		and Duel.GetMZoneCount(tp,e:GetHandler())>1
		-- 检查除外区是否存在满足条件的第1只「不知火」怪兽（从而确保能选出包含「不知火」怪兽的2只不死族怪兽）
		and Duel.IsExistingTarget(c79783880.spfilter1,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择第1只作为特殊召唤对象的不死族「不知火」怪兽
	local g1=Duel.SelectTarget(tp,c79783880.spfilter1,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择第2只作为特殊召唤对象的不死族怪兽（不能与第1只相同）
	local g2=Duel.SelectTarget(tp,c79783880.spfilter2,tp,LOCATION_REMOVED,0,1,1,g1,e,tp)
	g1:Merge(g2)
	-- 设置特殊召唤的操作信息，包含选中的2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,2,0,0)
end
-- 定义效果处理函数：添加特殊召唤限制，并将选择的对象怪兽守备表示特殊召唤，同时无效其效果
function c79783880.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个效果的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c79783880.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该特殊召唤限制效果给玩家
	Duel.RegisterEffect(e1,tp)
	-- 获取当前自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取当前连锁中仍与此效果有关联的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()==0 or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if g:GetCount()>ft then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	local tc=g:GetFirst()
	while tc do
		-- 将目标怪兽以表侧守备表示进行特殊召唤的单步处理
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
		tc=g:GetNext()
	end
	-- 完成特殊召唤的流程处理
	Duel.SpecialSummonComplete()
end
-- 限制只能特殊召唤不死族怪兽
function c79783880.splimit(e,c)
	return not c:IsRace(RACE_ZOMBIE)
end
