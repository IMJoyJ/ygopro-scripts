--光の創造神 ホルアクティ
-- 效果：
-- 这张卡不能通常召唤。把自己场上的原本卡名是「奥西里斯之天空龙」「欧贝利斯克之巨神兵」「太阳神之翼神龙」的怪兽各1只解放的场合才能特殊召唤。这张卡的特殊召唤不会被无效化。把这张卡特殊召唤的玩家决斗胜利。
function c10000040.initial_effect(c)
	-- 在卡片信息中记录提及了「奥西里斯之天空龙」「欧贝利斯克之巨神兵」「太阳神之翼神龙」的代码
	aux.AddCodeList(c,10000010,10000000,10000020)
	c:EnableReviveLimit()
	-- 把自己场上的原本卡名是「奥西里斯之天空龙」「欧贝利斯克之巨神兵」「太阳神之翼神龙」的怪兽各1只解放的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c10000040.spcon)
	e1:SetTarget(c10000040.sptg)
	e1:SetOperation(c10000040.spop)
	c:RegisterEffect(e1)
	-- 这张卡不能通常召唤。把自己场上的原本卡名是「奥西里斯之天空龙」「欧贝利斯克之巨神兵」「太阳神之翼神龙」的怪兽各1只解放的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)
	-- 这张卡的特殊召唤不会被无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e3)
	-- 把这张卡特殊召唤的玩家决斗胜利。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetOperation(c10000040.winop)
	c:RegisterEffect(e4)
end
-- 生成用于校验解放的三只怪兽原本卡名是否分别为「奥西里斯之天空龙」「欧贝利斯克之巨神兵」「太阳神之翼神龙」的过滤函数列表
c10000040.spchecks=aux.CreateChecks(Card.IsOriginalCodeRule,{10000020,10000000,10000010})
-- 检查自己场上是否拥有可用于特殊召唤的原本卡名为三神的怪兽各1只
function c10000040.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上可以解放的怪兽卡片组
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 检查可解放的卡片组中是否能各选出一只符合三神卡名要求的怪兽，且解放后怪兽区域有空位
	return g:CheckSubGroupEach(c10000040.spchecks,aux.mzctcheckrel,tp,REASON_SPSUMMON)
end
-- 让玩家选择用于特殊召唤哈拉克提而解放的三神怪兽对象，并缓存选择结果
function c10000040.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上可解放的怪兽卡片组
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 玩家从可解放卡片组中各选择一只符合三神原本卡名要求的怪兽
	local sg=g:SelectSubGroupEach(tp,c10000040.spchecks,true,aux.mzctcheckrel,tp,REASON_SPSUMMON)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤所需的解放操作，解放所选的三神怪兽
function c10000040.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的三神怪兽解放
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 特殊召唤成功后，执行让特殊召唤该卡的玩家决斗胜利的操作
function c10000040.winop(e,tp,eg,ep,ev,re,r,rp)
	local WIN_REASON_CREATORGOD=0x13
	local p=e:GetHandler():GetSummonPlayer()
	-- 判定当前特殊召唤的玩家因光之创造神效果获得决斗胜利
	Duel.Win(p,WIN_REASON_CREATORGOD)
end
