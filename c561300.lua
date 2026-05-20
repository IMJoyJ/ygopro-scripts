--猛毒マムシ
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。这张卡特殊召唤。对方场上没有怪兽存在的场合，作为代替在对方场上守备表示特殊召唤。
-- ②：自己准备阶段发动。自己受到500伤害。
-- ③：这张卡被除外的场合或者被效果送去墓地的场合，以对方场上1张里侧表示的魔法·陷阱卡为对象才能发动（不能对应这个发动把作为对象的卡发动）。那张卡破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：把手卡的这张卡给对方观看才能发动。这张卡特殊召唤。对方场上没有怪兽存在的场合，作为代替在对方场上守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己准备阶段发动。自己受到500伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"伤害效果"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.damcon)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
	-- ③：这张卡被除外的场合或者被效果送去墓地的场合，以对方场上1张里侧表示的魔法·陷阱卡为对象才能发动（不能对应这个发动把作为对象的卡发动）。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"破坏效果"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCondition(s.descon)
	e4:SetCode(EVENT_TO_GRAVE)
	c:RegisterEffect(e4)
end
-- 效果①的发动代价：确认手牌中的这张卡未公开（给对方观看）
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 效果①的发动准备与合法性检测：确定特殊召唤的玩家和表示形式，并检测是否有可用怪兽区域及是否能特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local sp=tp
	local pos=POS_FACEUP
	-- 若对方场上没有怪兽存在，则改变特殊召唤的玩家为对方，且表示形式为守备表示
	if not Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) then
		sp=1-tp
		pos=POS_FACEUP_DEFENSE
	end
	-- 检测目标玩家场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(sp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,pos,sp) end
	-- 设置特殊召唤的操作信息，包含这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：根据对方场上是否有怪兽决定特殊召唤的玩家和表示形式，并将这张卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sp=tp
	local pos=POS_FACEUP
	-- 效果处理时，若对方场上没有怪兽存在，则改变特殊召唤的玩家为对方，且表示形式为守备表示
	if not Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) then
		sp=1-tp
		pos=POS_FACEUP_DEFENSE
	end
	if c:IsRelateToChain() then
		-- 将这张卡特殊召唤到指定玩家的场上
		Duel.SpecialSummon(c,0,tp,sp,false,false,pos)
	end
end
-- 效果②的发动条件：当前回合玩家是自己
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 效果②的发动准备：设置受到伤害的玩家为自己，伤害数值为500，并设置伤害操作信息
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为500
	Duel.SetTargetParam(500)
	-- 设置造成伤害的操作信息，对象为自己，数值为500
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,500)
end
-- 效果②的效果处理：获取连锁信息并给予自己500点伤害
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家和对象参数（伤害数值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给予目标玩家指定数值的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 效果③（送入墓地时）的发动条件：这张卡因效果被送去墓地
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤函数：对方场上里侧表示的魔法·陷阱卡
function s.desfilter(c)
	return c:IsFacedown() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果③的发动准备：选择对方场上1张里侧表示的魔法·陷阱卡作为对象，并限制对方不能对应此发动将该卡发动
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.desfilter(chkc) and chkc:IsControler(1-tp) end
	-- 检测对方场上是否存在可以作为对象的里侧表示魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 在界面上提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张里侧表示的魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置破坏操作信息，包含选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁限制，防止对方对应此发动将作为对象的卡发动
	Duel.SetChainLimit(s.limit(g:GetFirst()))
end
-- 连锁限制函数：阻止作为对象的卡片在当前连锁中发动
function s.limit(c)
	return  function (e,lp,tp)
				return e:GetHandler()~=c
			end
end
-- 效果③的效果处理：破坏作为对象的卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsOnField() then
		-- 因效果破坏目标卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
