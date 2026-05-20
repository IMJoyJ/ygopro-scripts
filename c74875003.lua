--ラーの使徒
-- 效果：
-- ①：这张卡召唤·反转召唤·特殊召唤成功时才能发动。从手卡·卡组把最多2只「太阳神的使徒」特殊召唤。
-- ②：只要这张卡在怪兽区域存在，自己不用「太阳神的使徒」的效果不能把怪兽特殊召唤，这张卡不能为「奥西里斯之天空龙」「欧贝利斯克之巨神兵」「太阳神之翼神龙」的上级召唤以外而解放。
function c74875003.initial_effect(c)
	-- 在卡片中注册其记载了「奥西里斯之天空龙」、「太阳神之翼神龙」、「欧贝利斯克之巨神兵」的卡片密码
	aux.AddCodeList(c,10000010,10000000,10000020)
	-- ①：这张卡召唤·反转召唤·特殊召唤成功时才能发动。从手卡·卡组把最多2只「太阳神的使徒」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74875003,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c74875003.target)
	e1:SetOperation(c74875003.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 这张卡不能为「奥西里斯之天空龙」「欧贝利斯克之巨神兵」「太阳神之翼神龙」的上级召唤以外而解放。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UNRELEASABLE_SUM)
	e5:SetValue(c74875003.sumval)
	c:RegisterEffect(e5)
	-- 只要这张卡在怪兽区域存在，自己不用「太阳神的使徒」的效果不能把怪兽特殊召唤
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(1,0)
	e6:SetTarget(c74875003.splimit)
	c:RegisterEffect(e6)
end
-- 过滤函数：检索卡组或手卡中卡名为「太阳神的使徒」且可以特殊召唤的怪兽
function c74875003.filter(c,e,tp)
	return c:IsCode(74875003) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与可行性检测
function c74875003.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组中是否存在至少1张可以特殊召唤的「太阳神的使徒」
		and Duel.IsExistingMatchingCard(c74875003.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示该效果会从手卡或卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果①的效果处理：计算可召唤数量，并让玩家从手卡·卡组选择最多2只「太阳神的使徒」特殊召唤
function c74875003.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前玩家场上可用的怪兽区域空格数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>2 then ft=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 在系统提示框中显示“请选择要特殊召唤的卡”的信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组中选择1到ft张满足条件的「太阳神的使徒」
	local g=Duel.SelectMatchingCard(tp,c74875003.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到当前玩家的场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 限制解放的判定函数：如果解放的目的不是为了上级召唤三幻神，则不能解放
function c74875003.sumval(e,c)
	return not c:IsCode(10000000,10000010,10000020)
end
-- 特殊召唤限制的判定函数：如果特殊召唤的效果来源不是「太阳神的使徒」，则禁止该特殊召唤
function c74875003.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return se==nil or not se:GetHandler():IsCode(74875003)
end
