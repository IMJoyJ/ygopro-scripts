--ミミグル・ダンジョン
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这个回合没有召唤·特殊召唤的自己场上的「迷拟宝箱鬼」怪兽的攻击力上升自身的原本守备力数值。
-- ②：双方各自只要自身场上有里侧表示怪兽存在，不能把怪兽召唤，不能用这个回合特殊召唤的怪兽攻击宣言。
-- ③：自己主要阶段才能发动。从自己的卡组·墓地把1只「迷拟宝箱鬼」怪兽加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含场地魔法的发动、限制双方召唤、检索「迷拟宝箱鬼」怪兽、提升「迷拟宝箱鬼」怪兽攻击力、限制攻击宣言以及全局召唤/特殊召唤检测。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：双方各自只要自身场上有里侧表示怪兽存在，不能把怪兽召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetCondition(s.effcon1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetTargetRange(0,1)
	e3:SetCondition(s.effcon2)
	c:RegisterEffect(e3)
	-- ③：自己主要阶段才能发动。从自己的卡组·墓地把1只「迷拟宝箱鬼」怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))  --"加入手卡"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	-- ①：这个回合没有召唤·特殊召唤的自己场上的「迷拟宝箱鬼」怪兽的攻击力上升自身的原本守备力数值。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetValue(s.atkval)
	e5:SetTarget(s.atktg)
	c:RegisterEffect(e5)
	-- ②：双方各自只要自身场上有里侧表示怪兽存在，不能用这个回合特殊召唤的怪兽攻击宣言。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_CANNOT_ATTACK)
	e6:SetRange(LOCATION_FZONE)
	e6:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e6:SetTarget(s.atktarget)
	c:RegisterEffect(e6)
	if not s.global_check then
		s.global_check=true
		-- 这个卡名的③的效果1回合只能使用1次。①：这个回合没有召唤·特殊召唤的自己场上的「迷拟宝箱鬼」怪兽的攻击力上升自身的原本守备力数值。②：双方各自只要自身场上有里侧表示怪兽存在，不能把怪兽召唤，不能用这个回合特殊召唤的怪兽攻击宣言。③：自己主要阶段才能发动。从自己的卡组·墓地把1只「迷拟宝箱鬼」怪兽加入手卡。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		-- 注册全局通常召唤成功事件的监听效果，用于记录本回合被召唤的怪兽
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		-- 注册全局特殊召唤成功事件的监听效果，用于记录本回合被特殊召唤的怪兽
		Duel.RegisterEffect(ge2,0)
	end
end
-- 全局召唤/特殊召唤检测的执行函数，给本回合召唤的怪兽添加标记（如果是特殊召唤则额外添加特殊召唤标记），该标记在回合结束时重置
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TEMP_REMOVE+RESET_PHASE+PHASE_END,0,1)
		if tc:IsSummonType(SUMMON_TYPE_SPECIAL) then
			tc:RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD-RESET_TEMP_REMOVE+RESET_PHASE+PHASE_END,0,1)
		end
		tc=eg:GetNext()
	end
end
-- 攻击力上升效果的过滤条件：自己场上的「迷拟宝箱鬼」怪兽，且本回合没有被召唤或特殊召唤（即没有对应的全局标记）
function s.atktg(e,c)
	return c:IsSetCard(0x1b7) and c:GetFlagEffect(id)==0
end
-- 攻击力上升的数值：怪兽的原本守备力数值
function s.atkval(e,c)
	return c:GetBaseDefense()
end
-- 限制攻击宣言的过滤条件：该怪兽是本回合特殊召唤的，且其控制者场上存在里侧表示怪兽
function s.atktarget(e,c)
	-- 检查怪兽是否带有本回合特殊召唤的标记，且其控制者场上是否存在至少1只里侧表示怪兽
	return c:GetFlagEffect(id+1)>0 and Duel.IsExistingMatchingCard(Card.IsFacedown,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 限制自己召唤的条件：自己场上存在里侧表示怪兽
function s.effcon1(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己场上是否存在至少1只里侧表示怪兽
	return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_MZONE,0,1,nil)
end
-- 限制对方召唤的条件：对方场上存在里侧表示怪兽
function s.effcon2(e)
	local tp=e:GetHandlerPlayer()
	-- 检查对方场上是否存在至少1只里侧表示怪兽
	return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_MZONE,1,nil)
end
-- 检索/回收怪兽的过滤条件：属于「迷拟宝箱鬼」系列且可以加入手卡的怪兽
function s.thfilter(c)
	return c:IsSetCard(0x1b7) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索/回收效果的发动准备与合法性检测（Target阶段）
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组或墓地中是否存在至少1只满足条件的「迷拟宝箱鬼」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁处理信息：从卡组或墓地将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 检索/回收效果的执行函数（Operation阶段）
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要加入手卡的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或墓地选择1只满足条件的「迷拟宝箱鬼」怪兽（受「王家长眠之谷」影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	-- 如果成功选择到卡片，则通过效果将其加入手卡
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
		-- 让对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
