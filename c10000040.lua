--光の創造神 ホルアクティ
-- 效果：
-- 这张卡不能通常召唤。把自己场上的原本卡名是「奥西里斯之天空龙」「欧贝利斯克之巨神兵」「太阳神之翼神龙」的怪兽各1只解放的场合才能特殊召唤。这张卡的特殊召唤不会被无效化。把这张卡特殊召唤的玩家决斗胜利。
function c10000040.initial_effect(c)
	-- 将「奥西里斯之天空龙」、「欧贝利斯克之巨神兵」、「太阳神之翼神龙」的卡片密码写入此卡的关联卡片列表
	aux.AddCodeList(c,10000010,10000000,10000020)
	c:EnableReviveLimit()
	-- 手卡特殊召唤规则：解放场上原本卡名是「奥西里斯之天空龙」、「欧贝利斯克之巨神兵」、「太阳神之翼神龙」的怪兽各1只来特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c10000040.spcon)
	e1:SetTarget(c10000040.sptg)
	e1:SetOperation(c10000040.spop)
	c:RegisterEffect(e1)
	-- 特殊召唤限制
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)
	-- 此卡的特殊召唤不会被无效化
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e3)
	-- 特殊召唤成功时决斗胜利的效果
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetOperation(c10000040.winop)
	c:RegisterEffect(e4)
end
-- 检查原本卡名是否是「太阳神之翼神龙」、「欧贝利斯克之巨神兵」、「奥西里斯之天空龙」的辅助检查函数
c10000040.spchecks=aux.CreateChecks(Card.IsOriginalCodeRule,{10000020,10000000,10000010})
-- 手卡特殊召唤的条件判定函数
function c10000040.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家场上可以解放的怪兽群
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 检查是否能从可解放的怪兽中各选1只符合三幻神原本卡名的怪兽解放
	return g:CheckSubGroupEach(c10000040.spchecks,aux.mzctcheckrel,tp,REASON_SPSUMMON)
end
-- 手卡特殊召唤的目标选择函数
function c10000040.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家场上可以解放的怪兽群
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 提示选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 玩家选择原本卡名是三幻神的怪兽各1只
	local sg=g:SelectSubGroupEach(tp,c10000040.spchecks,true,aux.mzctcheckrel,tp,REASON_SPSUMMON)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 手卡特殊召唤的执行操作函数
function c10000040.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放选中的怪兽
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 决斗胜利的执行操作函数
function c10000040.winop(e,tp,eg,ep,ev,re,r,rp)
	local WIN_REASON_CREATORGOD=0x13
	local p=e:GetHandler():GetSummonPlayer()
	-- 宣告把此卡特殊召唤的玩家决斗胜利
	Duel.Win(p,WIN_REASON_CREATORGOD)
end
