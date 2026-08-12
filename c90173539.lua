--ワールド・ダイナ・レスリング
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：自己场上有「恐龙摔跤手」怪兽存在的场合，双方玩家在战斗阶段只能用1只怪兽攻击。
-- ②：自己的「恐龙摔跤手」怪兽的攻击力只在向对方怪兽攻击的伤害计算时上升200。
-- ③：对方场上的怪兽数量比自己场上的怪兽多的场合，把墓地的这张卡除外才能发动。从卡组把1只「恐龙摔跤手」怪兽特殊召唤。
function c90173539.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上有「恐龙摔跤手」怪兽存在的场合，双方玩家在战斗阶段只能用1只怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCondition(c90173539.atklimcon)
	e2:SetTarget(c90173539.atklimtg)
	c:RegisterEffect(e2)
	-- ①：自己场上有「恐龙摔跤手」怪兽存在的场合，双方玩家在战斗阶段只能用1只怪兽攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetOperation(c90173539.checkop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- ②：自己的「恐龙摔跤手」怪兽的攻击力只在向对方怪兽攻击的伤害计算时上升200。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(c90173539.atkcon)
	e4:SetTarget(c90173539.atktg)
	e4:SetValue(200)
	c:RegisterEffect(e4)
	-- ③：对方场上的怪兽数量比自己场上的怪兽多的场合，把墓地的这张卡除外才能发动。从卡组把1只「恐龙摔跤手」怪兽特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(90173539,0))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCountLimit(1,90173539)
	e5:SetCondition(c90173539.spcon)
	-- 把墓地的这张卡除外作为发动的代价
	e5:SetCost(aux.bfgcost)
	e5:SetTarget(c90173539.sptg)
	e5:SetOperation(c90173539.spop)
	c:RegisterEffect(e5)
end
-- 过滤条件：场上表侧表示的「恐龙摔跤手」怪兽
function c90173539.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x11a)
end
-- 攻击限制效果的适用条件：本回合已有怪兽进行过攻击，且自己场上有表侧表示的「恐龙摔跤手」怪兽存在
function c90173539.atklimcon(e)
	-- 检查本回合是否有怪兽进行过攻击，且自己场上是否存在表侧表示的「恐龙摔跤手」怪兽
	return e:GetHandler():GetFlagEffect(90173539)~=0 and Duel.IsExistingMatchingCard(c90173539.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 限制除第一只进行攻击宣言的怪兽以外的所有怪兽不能进行攻击
function c90173539.atklimtg(e,c)
	return c:GetFieldID()~=e:GetLabel()
end
-- 在有怪兽进行攻击宣言时，给这张卡添加标记，并记录第一只攻击怪兽的FieldID
function c90173539.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(90173539)~=0 then return end
	local fid=eg:GetFirst():GetFieldID()
	e:GetHandler():RegisterFlagEffect(90173539,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	e:GetLabelObject():SetLabel(fid)
end
-- 攻击力上升效果的适用条件：处于伤害计算阶段，且对方场上有作为攻击对象的怪兽存在
function c90173539.atkcon(e)
	-- 获取当前的攻击对象（被攻击的怪兽）
	local d=Duel.GetAttackTarget()
	local tp=e:GetHandlerPlayer()
	-- 判断当前是否为伤害计算时，且存在对方控制的被攻击怪兽
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and d and d:IsControler(1-tp)
end
-- 攻击力上升效果的适用对象：正在进行攻击的己方「恐龙摔跤手」怪兽
function c90173539.atktg(e,c)
	-- 判断该怪兽是否为当前进行攻击的「恐龙摔跤手」怪兽
	return c==Duel.GetAttacker() and c:IsSetCard(0x11a)
end
-- 特殊召唤效果的发动条件：对方场上的怪兽数量比自己场上的怪兽多
function c90173539.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 比较双方场上的怪兽数量，判断自己场上的怪兽数量是否小于对方场上的怪兽数量
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
end
-- 过滤条件：卡组中可以特殊召唤的「恐龙摔跤手」怪兽
function c90173539.spfilter(c,e,tp)
	return c:IsSetCard(0x11a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的靶向与可行性检查：检查自己场上是否有空位，且卡组中是否存在可特殊召唤的「恐龙摔跤手」怪兽
function c90173539.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，判断自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且检查卡组中是否存在至少1只满足特殊召唤条件的「恐龙摔跤手」怪兽
		and Duel.IsExistingMatchingCard(c90173539.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果的执行：从卡组选择1只「恐龙摔跤手」怪兽在自己场上特殊召唤
function c90173539.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上已无可用怪兽区域，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送选择特殊召唤卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只满足条件的「恐龙摔跤手」怪兽
	local g=Duel.SelectMatchingCard(tp,c90173539.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
