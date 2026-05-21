--サモン・リアクター・AI
-- 效果：
-- 只要这张卡在自己场上存在，对方场上有怪兽召唤、反转召唤、特殊召唤时，给与对方基本分800分伤害。这个效果1回合只能使用1次。这个效果使用的回合的战斗阶段时，可以把1只对方怪兽的攻击无效。可以把自己场上表侧表示存在的这张卡和「陷阱反应机·空式」「魔法反应机·袭式」各1只送去墓地，从自己的手卡·卡组·墓地把1只「巨人轰炸机·大空袭式」特殊召唤。
function c89493368.initial_effect(c)
	-- 只要这张卡在自己场上存在，对方场上有怪兽召唤、反转召唤、特殊召唤时，给与对方基本分800分伤害。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89493368,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCondition(c89493368.damcon)
	e1:SetTarget(c89493368.damtg)
	e1:SetOperation(c89493368.damop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 这个效果使用的回合的战斗阶段时，可以把1只对方怪兽的攻击无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(89493368,1))  --"攻击无效"
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetCondition(c89493368.nacon)
	e4:SetTarget(c89493368.natg)
	e4:SetOperation(c89493368.naop)
	c:RegisterEffect(e4)
	-- 可以把自己场上表侧表示存在的这张卡和「陷阱反应机·空式」「魔法反应机·袭式」各1只送去墓地，从自己的手卡·卡组·墓地把1只「巨人轰炸机·大空袭式」特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(89493368,2))  --"特殊召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCost(c89493368.spcost)
	e5:SetTarget(c89493368.sptg)
	e5:SetOperation(c89493368.spop)
	c:RegisterEffect(e5)
end
-- 创建用于检查场上是否存在「陷阱反应机·空式」和「魔法反应机·袭式」的条件检查函数数组
c89493368.spchecks=aux.CreateChecks(Card.IsCode,{15175429,52286175})
-- 伤害效果的发动条件：对方场上有怪兽召唤、反转召唤或特殊召唤成功
function c89493368.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
-- 伤害效果的准备阶段：给自身注册已发动效果的标记，并设置给与对方800分伤害的操作信息
function c89493368.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(89493368,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	-- 设置给与对方玩家800分伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 伤害效果的执行：若此卡仍在场，则给与对方800分伤害
function c89493368.damop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 给与对方玩家800分的效果伤害
		Duel.Damage(1-tp,800,REASON_EFFECT)
	end
end
-- 攻击无效效果的发动条件：对方怪兽进行攻击宣言，且本回合已发动过伤害效果
function c89493368.nacon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst():IsControler(1-tp) and e:GetHandler():GetFlagEffect(89493368)~=0
end
-- 攻击无效效果的准备阶段：获取攻击怪兽并将其设为效果处理的对象
function c89493368.natg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前进行攻击宣言的怪兽
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	-- 将进行攻击的怪兽设为本效果的对象
	Duel.SetTargetCard(tg)
end
-- 攻击无效效果的执行：若攻击怪兽仍适用效果，则无效该怪兽的攻击
function c89493368.naop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击的怪兽
	local tc=Duel.GetAttacker()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 无效当前的攻击
		Duel.NegateAttack()
	end
end
-- 过滤可以作为特殊召唤Cost送去墓地的「陷阱反应机·空式」或「魔法反应机·袭式」
function c89493368.spcostfilter(c)
	return c:IsAbleToGraveAsCost() and c:IsCode(15175429,52286175)
end
-- 检查将作为Cost的卡送去墓地后，自己场上是否有足够的怪兽区域用于特殊召唤
function c89493368.fgoal(g,tp,c)
	local sg=Group.FromCards(c)
	sg:Merge(g)
	-- 检查将指定的卡送去墓地后，自己场上的怪兽区域空位数是否大于0
	return Duel.GetMZoneCount(tp,sg)>0
end
-- 特殊召唤效果的Cost：将自身以及场上表侧表示的「陷阱反应机·空式」和「魔法反应机·袭式」各1只送去墓地
function c89493368.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取自己场上除自身以外可以作为Cost送去墓地的「陷阱反应机·空式」和「魔法反应机·袭式」
	local g=Duel.GetMatchingGroup(c89493368.spcostfilter,tp,LOCATION_MZONE,0,c)
	if chk==0 then return c:IsAbleToGraveAsCost() and g:CheckSubGroupEach(c89493368.spchecks,c89493368.fgoal,tp,c) end
	local sg=g:SelectSubGroupEach(tp,c89493368.spchecks,false,c89493368.fgoal,tp,c)
	sg:AddCard(c)
	-- 将选定的卡作为Cost送去墓地
	Duel.SendtoGrave(sg,REASON_COST)
end
-- 过滤手卡、卡组、墓地中可以无视召唤条件特殊召唤的「巨人轰炸机·大空袭式」
function c89493368.spfilter(c,e,tp)
	return c:IsCode(16898077) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 特殊召唤效果的准备阶段：检查是否存在可特殊召唤的「巨人轰炸机·大空袭式」，并设置特殊召唤的操作信息
function c89493368.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的手卡、卡组、墓地中是否存在至少1只满足特殊召唤条件的「巨人轰炸机·大空袭式」
	if chk==0 then return Duel.IsExistingMatchingCard(c89493368.spfilter,tp,0x13,0,1,nil,e,tp) end
	-- 设置从手卡、卡组、墓地特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 特殊召唤效果的执行：从手卡、卡组、墓地选择1只「巨人轰炸机·大空袭式」无视召唤条件特殊召唤
function c89493368.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡、卡组、墓地（受王家长眠之谷影响）中选择1只满足条件的「巨人轰炸机·大空袭式」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c89493368.spfilter),tp,0x13,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽无视召唤条件和苏生限制以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
		g:GetFirst():CompleteProcedure()
	end
end
