--光の創造神 ホルアクティ
-- 效果：
-- 这张卡不能通常召唤。把自己场上的原本卡名是「奥西里斯之天空龙」「欧贝利斯克之巨神兵」「太阳神之翼神龙」的怪兽各1只解放的场合才能特殊召唤。这张卡的特殊召唤不会被无效化。把这张卡特殊召唤的玩家决斗胜利。
function c10000040.initial_effect(c)
	-- 声明关联的三幻神卡片列表
	aux.AddCodeList(c,10000010,10000000,10000020)
	c:EnableReviveLimit()
	-- 特殊召唤手续：解放自己场上的三幻神各一只进行特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c10000040.spcon)
	e1:SetTarget(c10000040.sptg)
	e1:SetOperation(c10000040.spop)
	c:RegisterEffect(e1)
	-- 不能通常召唤
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)
	-- 这张卡的特殊召唤不会被无效化
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e3)
	-- 特殊召唤成功时，玩家决斗胜利
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetOperation(c10000040.winop)
	c:RegisterEffect(e4)
end
-- 生成检查三幻神原本卡名的过滤条件
c10000040.spchecks=aux.CreateChecks(Card.IsOriginalCodeRule,{10000020,10000000,10000010})
-- 特殊召唤条件：检查场上是否集齐原本卡名为三幻神的怪兽
function c10000040.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上可用于解放的怪兽组
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 检查是否能选出符合三幻神要求的怪兽组合进行解放
	return g:CheckSubGroupEach(c10000040.spchecks,aux.mzctcheckrel,tp,REASON_SPSUMMON)
end
-- 特殊召唤的目标选择操作
function c10000040.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取场上可用于解放的怪兽组
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 提示选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从场上选择并锁定原本卡名分别为三幻神的三只怪兽
	local sg=g:SelectSubGroupEach(tp,c10000040.spchecks,true,aux.mzctcheckrel,tp,REASON_SPSUMMON)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤的解放动作执行
function c10000040.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放选定的三幻神怪兽
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 胜利判定效果的实际操作
function c10000040.winop(e,tp,eg,ep,ev,re,r,rp)
	local WIN_REASON_CREATORGOD=0x13
	local p=e:GetHandler():GetSummonPlayer()
	-- 让特殊召唤此卡的玩家判定决斗胜利
	Duel.Win(p,WIN_REASON_CREATORGOD)
end
