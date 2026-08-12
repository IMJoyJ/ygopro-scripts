--ヴォルカニック・クイーン
-- 效果：
-- 这张卡不能通常召唤。把对方场上1只怪兽解放的场合可以在对方场上特殊召唤。把这张卡特殊召唤的回合，自己不能通常召唤。
-- ①：1回合1次，把自己场上1张其他卡送去墓地才能发动。给与对方1000伤害。
-- ②：自己结束阶段发动。自己场上1只其他怪兽解放或自己受到1000伤害。
function c63014935.initial_effect(c)
	c:EnableReviveLimit()
	-- 把对方场上1只怪兽解放的场合可以在对方场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(POS_FACEUP,1)
	e1:SetCondition(c63014935.spcon)
	e1:SetTarget(c63014935.sptg)
	e1:SetOperation(c63014935.spop)
	c:RegisterEffect(e1)
	-- ①：1回合1次，把自己场上1张其他卡送去墓地才能发动。给与对方1000伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63014935,0))  --"给与对方1000伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c63014935.damcost)
	e2:SetTarget(c63014935.damtg)
	e2:SetOperation(c63014935.damop)
	c:RegisterEffect(e2)
	-- ②：自己结束阶段发动。自己场上1只其他怪兽解放或自己受到1000伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(63014935,1))  --"选择祭品或受伤害"
	e3:SetCategory(CATEGORY_RELEASE+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c63014935.phcon)
	e3:SetOperation(c63014935.phop)
	c:RegisterEffect(e3)
	-- 把这张卡特殊召唤的回合，自己不能通常召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SPSUMMON_COST)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCost(c63014935.spcost)
	e4:SetOperation(c63014935.spcop)
	c:RegisterEffect(e4)
end
-- 特殊召唤规则的解放怪兽过滤条件（对方场上可解放且有可用怪兽区域的怪兽）
function c63014935.spfilter(c,tp)
	-- 检查怪兽是否可以因特殊召唤而解放，且解放后对方场上有可用的怪兽区域
	return c:IsReleasable(REASON_SPSUMMON) and Duel.GetMZoneCount(1-tp,c,tp)>0
end
-- 特殊召唤规则的出现条件（对方场上存在至少1只满足解放条件的怪兽）
function c63014935.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查对方场上是否存在至少1只满足解放条件的怪兽
	return Duel.IsExistingMatchingCard(c63014935.spfilter,tp,0,LOCATION_MZONE,1,nil,tp)
end
-- 特殊召唤规则的目标选择（玩家选择对方场上1只准备解放的怪兽）
function c63014935.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取对方场上所有满足解放条件的怪兽组
	local g=Duel.GetMatchingGroup(c63014935.spfilter,tp,0,LOCATION_MZONE,nil,tp)
	-- 给玩家发送选择要解放卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的执行操作（解放选中的怪兽）
function c63014935.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放选中的怪兽（作为特殊召唤的媒介）
	Duel.Release(g,REASON_SPSUMMON)
end
-- 伤害效果的发动代价（将自己场上1张其他卡送去墓地）
function c63014935.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 步骤0：检查自己场上是否存在除这张卡以外可以送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 给玩家发送选择要送去墓地卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择自己场上1张除这张卡以外的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 将选中的卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 伤害效果的发动准备（设置伤害对象和伤害数值）
function c63014935.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果的对象参数为1000（伤害值）
	Duel.SetTargetParam(1000)
	-- 设置当前连锁的操作信息为给与对方1000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,1-tp,1000)
end
-- 伤害效果的执行操作（给与对方1000点伤害）
function c63014935.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的伤害对象玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与目标玩家对应的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 结束阶段效果的发动条件（当前回合玩家的结束阶段）
function c63014935.phcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为这张卡的控制者（即“自己结束阶段”）
	return Duel.GetTurnPlayer()==tp
end
-- 结束阶段效果的执行操作（选择解放自己场上1只其他怪兽或自己受到1000伤害）
function c63014935.phop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在除这张卡以外可解放的怪兽，并由玩家选择是否进行解放
	if Duel.CheckReleaseGroupEx(tp,aux.TRUE,1,REASON_EFFECT,false,e:GetHandler()) and Duel.SelectYesNo(tp,aux.Stringid(63014935,2)) then  --"是否要解放一只怪兽？"
		-- 玩家选择并解放自己场上1只除这张卡以外的怪兽
		Duel.Release(Duel.SelectReleaseGroupEx(tp,aux.TRUE,1,1,REASON_EFFECT,false,e:GetHandler()),REASON_EFFECT)
	-- 若不选择解放怪兽（或无法解放），则自己受到1000点伤害
	else Duel.Damage(tp,1000,REASON_EFFECT) end
end
-- 特殊召唤的限制条件检测（检查本回合是否进行过通常召唤）
function c63014935.spcost(e,c,tp)
	-- 检查玩家本回合通常召唤（包括放置）的次数是否为0
	return Duel.GetActivityCount(tp,ACTIVITY_NORMALSUMMON)==0
end
-- 特殊召唤成功后的限制适用（本回合不能通常召唤）
function c63014935.spcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 把这张卡特殊召唤的回合，自己不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 给玩家注册本回合不能召唤怪兽的效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_MSET)
	-- 给玩家注册本回合不能通常召唤放置怪兽的效果
	Duel.RegisterEffect(e2,tp)
end
