--光の創造神 ホルアクティ
-- 效果：
-- 这张卡不能通常召唤。把自己场上的原本卡名是「奥西里斯之天空龙」「欧贝利斯克之巨神兵」「太阳神之翼神龙」的怪兽各1只解放的场合才能特殊召唤。这张卡的特殊召唤不会被无效化。把这张卡特殊召唤的玩家决斗胜利。
function c10000040.initial_effect(c)
	-- 为卡片注册相关的卡片代码列表，标明该卡与「奥西里斯之天空龙」「欧贝利斯克之巨神兵」「太阳神之翼神龙」有关联
	aux.AddCodeList(c,10000010,10000000,10000020)
	c:EnableReviveLimit()
	-- 设置特殊召唤规则效果：需要解放指定三张神之卡才能从手牌特殊召唤，且此特殊召唤不会被无效化
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c10000040.spcon)
	e1:SetTarget(c10000040.sptg)
	e1:SetOperation(c10000040.spop)
	c:RegisterEffect(e1)
	-- 设定特殊召唤条件效果，使此卡的特殊召唤无法被无效化
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)
	-- 设定特殊召唤不可无效的效果，确保特殊召唤过程不受到其他效果影响
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e3)
	-- 设定特殊召唤成功时触发的连续型效果，用于判定并执行决斗胜利逻辑
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetOperation(c10000040.winop)
	c:RegisterEffect(e4)
end
-- 创建一组检查函数，用于验证是否能正确地选择并解放指定的三张神之卡
c10000040.spchecks=aux.CreateChecks(Card.IsOriginalCodeRule,{10000020,10000000,10000010})
-- 定义特殊召唤条件判断函数，用于检测能否满足特殊召唤所需的解放条件
function c10000040.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取当前玩家场上可用于特殊召唤代价的可解放卡片组
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 检查是否存在符合条件的子组合（各1只指定神之卡）并且能够正常进行解放操作
	return g:CheckSubGroupEach(c10000040.spchecks,aux.mzctcheckrel,tp,REASON_SPSUMMON)
end
-- 定义特殊召唤目标选择函数，在选择阶段提示并处理解放对象的选择
function c10000040.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 再次获取当前玩家场上可用于特殊召唤代价的可解放卡片组
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 向玩家显示选择提示信息，引导其选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	-- 让玩家选择符合要求的卡片组合（每种神之卡各一只）作为解放对象，并确认是否可以完成特殊召唤
	local sg=g:SelectSubGroupEach(tp,c10000040.spchecks,true,aux.mzctcheckrel,tp,REASON_SPSUMMON)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 定义特殊召唤操作函数，负责实际执行解放所选卡片的操作
function c10000040.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以特殊召唤为原因解放之前选定的卡片组
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 定义特殊召唤成功后的操作函数，用于触发胜利判定
function c10000040.winop(e,tp,eg,ep,ev,re,r,rp)
	local WIN_REASON_CREATORGOD=0x13
	local p=e:GetHandler():GetSummonPlayer()
	-- 宣告特殊召唤该卡的玩家获得决斗胜利
	Duel.Win(p,WIN_REASON_CREATORGOD)
end
