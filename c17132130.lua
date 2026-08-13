--D-HERO ドグマガイ
-- 效果：
-- 这张卡不能通常召唤。把包含「命运英雄」怪兽的自己场上3只怪兽解放的场合才能特殊召唤。
-- ①：这个方法让这张卡特殊召唤成功的场合，下次的对方准备阶段发动。对方基本分变成一半。
function c17132130.initial_effect(c)
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置EFFECT_SPSUMMON_CONDITION的判定值为FALSE，使该卡不能用常规效果特殊召唤，只能通过e2的规则特殊召唤方式上场。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 把包含「命运英雄」怪兽的自己场上3只怪兽解放的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17132130,0))  --"特殊召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetValue(SUMMON_VALUE_SELF)
	e2:SetCondition(c17132130.spcon)
	e2:SetTarget(c17132130.sptg)
	e2:SetOperation(c17132130.spop)
	c:RegisterEffect(e2)
	-- ①：这个方法让这张卡特殊召唤的场合，下次的对方准备阶段发动。对方基本分变成一半。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c17132130.lp)
	e3:SetOperation(c17132130.lpop)
	c:RegisterEffect(e3)
	c:EnableReviveLimit()
end
-- 作为解放素材的筛选条件：怪兽必须是「命运英雄」（0xc008）字段，且由tp控制或表侧表示（允许解放可用的表侧命运英雄）。
function c17132130.rfilter(c,tp)
	return c:IsSetCard(0xc008) and (c:IsControler(tp) or c:IsFaceup())
end
-- 检查所选3张解放素材是否合法：其中至少包含1只满足rfilter的「命运英雄」怪兽，并且通过aux.mzctcheckrel确认解放后仍有主怪兽区空位可特殊召唤。
function c17132130.fselect(g,tp)
	-- 所选解放组至少要存在1只符合条件的「命运英雄」怪兽，且释放后场上仍有足够区域可进行特殊召唤。
	return g:IsExists(c17132130.rfilter,1,nil,tp) and aux.mzctcheckrel(g,tp,REASON_SPSUMMON)
end
-- 特殊召唤规则的条件：若c为nil（规则查询）直接可用；否则获取tp可解放的怪兽组，判断其中是否存在3张可通过fselect检验的解放素材。
function c17132130.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家tp可解放的怪兽组（不包含手牌，解放原因为特殊召唤），以用于筛选解放素材。
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	return rg:CheckSubGroup(c17132130.fselect,3,3,tp)
end
-- 特殊召唤手续的发动/目标选择阶段：从可解放组中提示玩家选择3张满足fselect条件的怪兽；若选到则保存该组到效果Label并返回true，否则返回false。
function c17132130.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取可解放的怪兽组（不含手牌，解放原因指定为特殊召唤），作为玩家选择解放素材的候选集合。
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 向tp玩家显示选择提示，提示内容为“请选择要解放的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=rg:SelectSubGroup(tp,c17132130.fselect,true,3,3,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤手续的执行阶段：取出之前保存的解放素材组，将其解放，然后清理临时组的引用。
function c17132130.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以REASON_SPSUMMON为解放原因解放选中的素材怪兽，完成规则特殊召唤代价支付。
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 触发条件：判定这张卡是否通过自身规则效果（SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF）成功特殊召唤，是则本效果才可发动。
function c17132130.lp(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 特殊召唤成功时，为这张卡注册一个在下次对方准备阶段发动的诱发必发效果，效果为对方LP减半，并设置该效果仅能发动一次且随后重置。
function c17132130.lpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 下次的对方准备阶段发动。对方基本分变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17132130,1))  --"LP减半"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_EVENT+0x2fe0000+RESET_PHASE+PHASE_STANDBY)
	e1:SetCondition(c17132130.lpc)
	e1:SetOperation(c17132130.lpcop)
	c:RegisterEffect(e1)
end
-- 该效果的发动条件：当前不是这张卡控制者的回合，即处于对方准备阶段，保证在下次对方准备阶段发动。
function c17132130.lpc(e,tp,eg,ep,ev,re,r,rp)
	-- 判定tp不是当前回合玩家，用于确认当前阶段是对方准备阶段。
	return tp~=Duel.GetTurnPlayer()
end
-- 效果处理：将对方玩家的基本分变为原来的一半（向上取整），使对方基本分减半。
function c17132130.lpcop(e,tp,eg,ep,ev,re,r,rp)
	-- 把1-tp玩家的LP设为原LP除以2后向上取整的结果，执行对方LP减半的操作。
	Duel.SetLP(1-tp,math.ceil(Duel.GetLP(1-tp)/2))
end
