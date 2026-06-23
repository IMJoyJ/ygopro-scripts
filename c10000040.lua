--光の創造神 ホルアクティ
-- 效果：
-- 这张卡不能通常召唤。把自己场上的原本卡名是「奥西里斯之天空龙」「欧贝利斯克之巨神兵」「太阳神之翼神龙」的怪兽各1只解放的场合才能特殊召唤。这张卡的特殊召唤不会被无效化。把这张卡特殊召唤的玩家决斗胜利。
function c10000040.initial_effect(c)
	-- 将卡片「奥西里斯之天空龙」「欧贝利斯克之巨神兵」「太阳神之翼神龙」的代码添加到当前卡片的代码列表中，用于后续的检索和判断。
	aux.AddCodeList(c,10000010,10000000,10000020)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把自己场上的原本卡名是「奥西里斯之天空龙」「欧贝利斯克之巨神兵」「太阳神之翼神龙」的怪兽各1只解放的场合才能特殊召唤。这张卡的特殊召唤不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c10000040.spcon)
	e1:SetTarget(c10000040.sptg)
	e1:SetOperation(c10000040.spop)
	c:RegisterEffect(e1)
	-- 创建一个效果，设置该效果为不可失效、不可复制的单次效果，并将其注册到当前卡片上，用于限制特殊召唤条件。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)
	-- 创建一个效果，设置该效果为不可失效、不可复制的单次效果，并将其注册到当前卡片上，用于防止特殊召唤被无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e3)
	-- 创建一个效果，设置该效果为持续型且不可失效、不可复制的效果，并在特殊召唤成功时触发，使玩家获得胜利。这张卡不能通常召唤。把自己场上的原本卡名是「奥西里斯之天空龙」「欧贝利斯克之巨神兵」「太阳神之翼神龙」的怪兽各1只解放的场合才能特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetOperation(c10000040.winop)
	c:RegisterEffect(e4)
end
-- 创建一个过滤函数列表，用于检查卡片的原始代码是否为指定的代码（即「奥西里斯之天空龙」「欧贝利斯克之巨神兵」「太阳神之翼神龙」），方便后续筛选符合条件的怪兽。
c10000040.spchecks=aux.CreateChecks(Card.IsOriginalCodeRule,{10000020,10000000,10000010})
-- 定义特殊召唤条件判断函数：如果当前卡片为空，则返回true；获取控制者的可解放怪兽组；检查该怪兽组是否包含满足原始代码规则的怪兽，并验证释放后主怪兽区是否有足够的空位。
function c10000040.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家的可解放怪兽组，用于后续选择要解放的怪兽。这张卡不能通常召唤。把自己场上的原本卡名是「奥西里斯之天空龙」「欧贝利斯克之巨神兵」「太阳神之翼神龙」的怪兽各1只解放的场合才能特殊召唤。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 检查可解放怪兽组中是否存在满足原始代码规则的怪兽，并验证释放后主怪兽区是否有足够的空位。这张卡不能通常召唤。把自己场上的原本卡名是「奥西里斯之天空龙」「欧贝利斯克之巨神兵」「太阳神之翼神龙」的怪兽各1只解放的场合才能特殊召唤。
	return g:CheckSubGroupEach(c10000040.spchecks,aux.mzctcheckrel,tp,REASON_SPSUMMON)
end
-- 定义特殊召唤目标选择函数：获取玩家的可解放怪兽组；向玩家提示“请选择要解放的卡”；从可解放怪兽组中选择满足原始代码规则的怪兽，并验证释放后主怪兽区是否有足够的空位。这张卡不能通常召唤。把自己场上的原本卡名是「奥西里斯之天空龙」「欧贝利斯克之巨神兵」「太阳神之翼神龙」的怪兽各1只解放的场合才能特殊召唤。
function c10000040.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家的可解放怪兽组，用于后续选择要解放的怪兽。这张卡不能通常召唤。把自己场上的原本卡名是「奥西里斯之天空龙」「欧贝利斯克之巨神兵」「太阳神之翼神龙」的怪兽各1只解放的场合才能特殊召唤。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 向玩家发送提示信息，要求选择要解放的卡片。这张卡不能通常召唤。把自己场上的原本卡名是「奥西里斯之天空龙」「欧贝利斯克之巨神兵」「太阳神之翼神龙」的怪兽各1只解放的场合才能特殊召唤。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从可解放怪兽组中选择满足原始代码规则的怪兽，并验证释放后主怪兽区是否有足够的空位。这张卡不能通常召唤。把自己场上的原本卡名是「奥西里斯之天空龙」「欧贝利斯克之巨神兵」「太阳神之翼神龙」的怪兽各1只解放的场合才能特殊召唤。
	local sg=g:SelectSubGroupEach(tp,c10000040.spchecks,true,aux.mzctcheckrel,tp,REASON_SPSUMMON)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 定义特殊召唤执行函数：获取已选择的要解放的怪兽组；将该怪兽组解放；删除该怪兽组。这张卡不能通常召唤。把自己场上的原本卡名是「奥西里斯之天空龙」「欧贝利斯克之巨神兵」「太阳神之翼神龙」的怪兽各1只解放的场合才能特殊召唤。
function c10000040.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将已选择的要解放的怪兽组进行解放。这张卡不能通常召唤。把自己场上的原本卡名是「奥西里斯之天空龙」「欧贝利斯克之巨神兵」「太阳神之翼神龙」的怪兽各1只解放的场合才能特殊召唤。
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 定义决斗胜利函数：设置一个用于表示创世神胜利的原因代码；获取当前卡片的召唤者玩家；使该玩家以指定原因获得决斗胜利。把这张卡特殊召唤的玩家决斗胜利。
function c10000040.winop(e,tp,eg,ep,ev,re,r,rp)
	local WIN_REASON_CREATORGOD=0x13
	local p=e:GetHandler():GetSummonPlayer()
	-- 使指定的玩家以创世神胜利的原因代码获得决斗胜利。把这张卡特殊召唤的玩家决斗胜利。
	Duel.Win(p,WIN_REASON_CREATORGOD)
end
