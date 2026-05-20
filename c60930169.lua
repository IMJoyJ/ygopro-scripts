--ブロークン・ブロッカー
-- 效果：
-- 自己场上存在的守备力比攻击力高的守备表示怪兽被战斗破坏的场合才能发动。和那只怪兽同名怪兽最多2只从自己卡组表侧守备表示特殊召唤。
function c60930169.initial_effect(c)
	-- 自己场上存在的守备力比攻击力高的守备表示怪兽被战斗破坏的场合才能发动。和那只怪兽同名怪兽最多2只从自己卡组表侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c60930169.condition)
	e1:SetTarget(c60930169.target)
	e1:SetOperation(c60930169.activate)
	c:RegisterEffect(e1)
	if not c60930169.global_check then
		c60930169.global_check=true
		-- 自己场上存在的守备力比攻击力高的守备表示怪兽被战斗破坏的场合才能发动。和那只怪兽同名怪兽最多2只从自己卡组表侧守备表示特殊召唤。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLED)
		ge1:SetOperation(c60930169.checkop)
		-- 在全局环境注册用于检测战斗破坏怪兽状态的延迟触发效果
		Duel.RegisterEffect(ge1,0)
	end
end
-- 伤害计算时，检测进行战斗的怪兽是否为守备表示、守备力大于攻击力且确定被战斗破坏，若是则为其注册标记
function c60930169.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local t=Duel.GetAttackTarget()
	if a and a:IsDefensePos() and a:GetDefense()>a:GetAttack() and a:IsStatus(STATUS_BATTLE_DESTROYED) then
		a:RegisterFlagEffect(60930169,RESET_PHASE+PHASE_DAMAGE,0,1)
	end
	if t and t:IsDefensePos() and t:GetDefense()>t:GetAttack() and t:IsStatus(STATUS_BATTLE_DESTROYED) then
		t:RegisterFlagEffect(60930169,RESET_PHASE+PHASE_DAMAGE,0,1)
	end
end
-- 过滤被战斗破坏的怪兽中，带有特定标记且原本控制者为发动效果玩家的怪兽，并记录其卡片密码
function c60930169.filter(c,e,tp)
	if c:GetFlagEffect(60930169)~=0 and c:IsPreviousControler(tp) then
		e:SetLabel(c:GetCode())
		return true
	else return false end
end
-- 检查被战斗破坏的怪兽组中是否存在满足条件的怪兽
function c60930169.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c60930169.filter,1,nil,e,tp)
end
-- 过滤卡组中与被破坏怪兽同名且可以表侧守备表示特殊召唤的怪兽
function c60930169.spfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动的靶向检测，确认自己场上有空位且卡组中存在至少1张同名怪兽
function c60930169.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组中是否存在至少1张与被破坏怪兽同名的可特殊召唤怪兽
		and Duel.IsExistingMatchingCard(c60930169.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,e:GetLabel()) end
	-- 设置当前连锁的操作信息，表示此效果包含从卡组特殊召唤怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，从卡组选择最多2只同名怪兽表侧守备表示特殊召唤
function c60930169.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 计算当前可特殊召唤的最大数量（怪兽区域空位数与2的较小值）
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),2)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 给玩家发送选择特殊召唤卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1到ft张与被破坏怪兽同名的怪兽
	local g=Duel.SelectMatchingCard(tp,c60930169.spfilter,tp,LOCATION_DECK,0,1,ft,nil,e,tp,e:GetLabel())
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
