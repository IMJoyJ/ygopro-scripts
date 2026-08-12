--溶岩魔神ラヴァ・ゴーレム
-- 效果：
-- 这张卡不能通常召唤。把对方场上2只怪兽解放的场合可以在对方场上特殊召唤。把这张卡特殊召唤的回合，自己不能通常召唤。
-- ①：自己准备阶段发动。自己受到1000伤害。
function c102380.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把对方场上2只怪兽解放的场合可以从手卡在对方场上表侧表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(102380,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(POS_FACEUP,1)
	e1:SetCondition(c102380.spcon)
	e1:SetTarget(c102380.sptg)
	e1:SetOperation(c102380.spop)
	c:RegisterEffect(e1)
	-- 这张卡的控制者的准备阶段发动。控制者受到1000伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetDescription(aux.Stringid(102380,1))  --"1000伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c102380.damcon)
	e2:SetTarget(c102380.damtg)
	e2:SetOperation(c102380.damop)
	c:RegisterEffect(e2)
	-- 特殊召唤的限制条件：把这张卡特殊召唤的回合，自己不能进行通常召唤（包括覆盖）。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SPSUMMON_COST)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCost(c102380.spcost)
	e3:SetOperation(c102380.spcop)
	c:RegisterEffect(e3)
end
-- 判断将选中的怪兽解放后，是否能有空余位置将此卡召唤到对方场上。
function c102380.fselect(g,tp)
	-- 计算解放指定怪兽后对方场上的空余怪兽区域是否大于0。
	return Duel.GetMZoneCount(1-tp,g,tp)>0
end
-- 特殊召唤效果的条件判断函数：对方场上必须有至少2只可解放的怪兽。
function c102380.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取对方场上所有可以因特殊召唤而解放的怪兽。
	local rg=Duel.GetMatchingGroup(Card.IsReleasable,tp,0,LOCATION_MZONE,nil,REASON_SPSUMMON)
	return rg:CheckSubGroup(c102380.fselect,2,2,tp)
end
-- 选择要解放的对方场上怪兽的逻辑。
function c102380.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取对方场上可解放的怪兽组。
	local rg=Duel.GetMatchingGroup(Card.IsReleasable,tp,0,LOCATION_MZONE,nil,REASON_SPSUMMON)
	-- 提示语：选择要解放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=rg:SelectSubGroup(tp,c102380.fselect,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤时的怪兽解放操作。
function c102380.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放选中的对方场上怪兽。
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 伤害效果发动条件判定函数：必须是当前控制者的准备阶段。
function c102380.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前回合玩家是否是此卡的控制者。
	return Duel.GetTurnPlayer()==tp
end
-- 伤害效果的对象确认与效果准备逻辑。
function c102380.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害的承受玩家为此卡当前的控制者。
	Duel.SetTargetPlayer(tp)
	-- 设置伤害数值为1000。
	Duel.SetTargetParam(1000)
	-- 设置给与伤害的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,1000)
end
-- 执行给与控制者1000伤害的操作。
function c102380.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取伤害的承受玩家和伤害数值参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果给与玩家伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 特殊召唤代价判定函数：自己本回合未进行过通常召唤。
function c102380.spcost(e,c,tp)
	-- 检查本回合自己通常召唤（包括覆盖）的次数是否为0。
	return Duel.GetActivityCount(tp,ACTIVITY_NORMALSUMMON)==0
end
-- 注册召唤限制誓约：特殊召唤此卡后本回合自己不能通常召唤。
function c102380.spcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 在本回合内，禁止玩家进行通常召唤与覆盖（Set）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 注册禁止玩家通常召唤的效果。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_MSET)
	-- 注册禁止玩家覆盖怪兽的效果。
	Duel.RegisterEffect(e2,tp)
end
