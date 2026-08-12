--スカーレッド・ノヴァ・ドラゴン－バーニング・ソウル
-- 效果：
-- 调整2只＋调整以外的怪兽1只
-- 这张卡用同调召唤以及以下方法才能特殊召唤。
-- ●从自己墓地把调整2只和「红莲魔龙」1只除外的场合可以从额外卡组特殊召唤。这个卡名的①的效果在自己把「红莲魔龙」同调召唤的决斗中才能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从自己墓地把1张卡加入手卡，这张卡的攻击力上升2000。
-- ②：场上的这张卡不会被效果破坏。
local s,id,o=GetID()
-- 在卡片效果初始化函数中，添加同调召唤手续，启用苏生限制，注册特殊召唤条件e1、从墓地除外素材进行特召规则e2、特召成功诱发的回收并加攻效果e3、不会被效果破坏效果e4、红莲魔龙同调限制标记e5，并注册一个全局的同调召唤红莲魔龙检测器ge1。
function s.initial_effect(c)
	-- 在卡片信息中记录该卡记载了「红莲魔龙」（卡号：70902743）的卡名。
	aux.AddCodeList(c,70902743)
	-- 为该卡注册正规的同调召唤手续：调整怪兽2只，加上调整以外的怪兽1只。
	aux.AddSynchroMixProcedure(c,aux.Tuner(nil),aux.Tuner(nil),nil,aux.NonTuner(nil),1,1)
	c:EnableReviveLimit()
	-- 这张卡用同调召唤以及以下方法才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设定该卡只有在通过同调召唤（或满足后续特召规则）的召唤方式下才能被特殊召唤。
	e1:SetValue(aux.synlimit)
	c:RegisterEffect(e1)
	-- ●从自己墓地把调整2只和「红莲魔龙」1只除外的场合可以从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 这个卡名的①的效果在自己把「红莲魔龙」同调召唤的决斗中才能使用1次。①：这张卡特殊召唤的场合才能发动。从自己墓地把1张卡加入手卡，这张卡的攻击力上升2000。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"回收效果"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL)
	e3:SetCondition(s.thcon)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	-- ②：场上的这张卡不会被效果破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- 注册卡片自身的特定内部标记效果，用以处理与红莲魔龙或相关机制的交互逻辑。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetCode(21142671)
	c:RegisterEffect(e5)
	if not s.global_flag then
		s.global_flag=true
		-- 这个卡名的①的效果在自己把「红莲魔龙」同调召唤的决斗中才能使用1次。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.regop)
		-- 将用于在决斗中检测是否有人成功同调召唤过「红莲魔龙」的全局侦听效果注册给系统。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 全局特殊召唤侦听函数：一旦有「红莲魔龙」成功同调召唤，就在该同调召唤玩家身上注册本卡密码的Flag标记效果作为已达成条件的凭证。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 使用迭代器循环遍历当前这组被特殊召唤的所有卡片。
	for tc in aux.Next(eg) do
		if tc:IsCode(70902743) and tc:IsSummonType(SUMMON_TYPE_SYNCHRO) then
			-- 如果检测到同调召唤了「红莲魔龙」，给该同调召唤的玩家注册本卡密码的Flag标记。
			Duel.RegisterFlagEffect(tc:GetSummonPlayer(),id,0,0,0)
		end
	end
end
-- 过滤函数：用于筛选墓地里可以作为特召Cost除外的「红莲魔龙」怪兽或调整怪兽。
function s.cfilter(c,tp)
	return (c:IsType(TYPE_MONSTER) and c:IsCode(70902743) or c:IsType(TYPE_TUNER))
		and c:IsAbleToRemoveAsCost() and c:IsAbleToRemove(tp,POS_FACEUP,REASON_SPSUMMON)
end
-- 辅助过滤函数：检测指定的除外卡片组g中是否包含有「红莲魔龙」以及另外至少2只调整怪兽。
function s.cfilter2(c,g)
	return c:IsCode(70902743) and g:IsExists(Card.IsType,2,c,TYPE_TUNER)
end
-- 辅助过滤函数：检测选定的除外卡片组g是否满足包含1只「红莲魔龙」和2只调整怪兽的素材结构条件。
function s.fselect(g)
	return g:IsExists(s.cfilter2,1,nil,g)
end
-- 特召规则的发动条件校验函数：校验额外卡组的空余怪兽区域，以及墓地是否存在符合条件的1只「红莲魔龙」与2只调整怪兽。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己墓地中所有可以被作为该特召规则Cost除外的怪兽的卡片组。
	local fg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil,tp)
	return fg:CheckSubGroup(s.fselect,3,3)
		-- 检查从额外卡组特殊召唤该怪兽时是否有空余的额外怪兽区域。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 特召规则的目标选择函数：由玩家从墓地选择1只「红莲魔龙」与2只调整怪兽作为除外素材，并将其保存在效果对象中。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local cp=c:GetControler()
	-- 获取玩家墓地中可用于该特殊召唤规则除外的所有怪兽的卡片组。
	local g=Duel.GetMatchingGroup(s.cfilter,cp,LOCATION_GRAVE,0,nil,cp)
	-- 向玩家发送提示，指示选择作为召唤Cost除外的素材卡片。
	Duel.Hint(HINT_SELECTMSG,cp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(cp,s.fselect,true,3,3)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特召规则的处理函数：将被选为特殊召唤素材的卡片设置给该卡，并执行除外操作。
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	c:SetMaterial(sg)
	-- 将作为召唤素材选择的怪兽因特殊召唤的原因以表侧表示除外。
	Duel.Remove(sg,POS_FACEUP,REASON_SPSUMMON)
end
-- 回收效果的触发条件校验函数：检查发动效果的玩家在决斗中是否曾经成功同调召唤过「红莲魔龙」。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查该玩家是否拥有之前同调召唤「红莲魔龙」时注册的决斗全程Flag标记。
	return Duel.GetFlagEffect(tp,id)>0
end
-- 回收效果的决斗中限使用一次的誓约Cost注册处理函数。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	-- 这个卡名的①的效果在自己把「红莲魔龙」同调召唤的决斗中才能使用1次。①：这张卡特殊召唤的场合才能发动。从自己墓地把1张卡加入手卡，这张卡的攻击力上升2000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))  --"已经使用过「真红莲新星龙-燃烧之魂」的①的效果"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	-- 为玩家注册该效果在一场决斗中仅能使用一次的誓约提示效果。
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数：用于筛选墓地中可以加入手牌的卡片。
function s.thfilter(c)
	return c:IsAbleToHand()
end
-- 回收效果的发动目标校验与操作信息设置函数，检查墓地是否有能加入手牌的卡，并设置回收的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 校验回收效果的可行性：检查墓地中是否存在可以加入手牌的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁处理的操作信息，声明本次效果会将墓地中的1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 回收效果的处理函数：让玩家从墓地选择1张卡加入手牌，回收成功且该卡仍在场上表侧表示存在时，使此卡的攻击力永久上升2000。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向玩家发送提示，指示选择要从墓地回收加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从墓地中选择1张卡，此操作需要受到王家长眠之谷的规则限制检测。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 手动为被选择回收的墓地卡片显示选定时的动画效果。
		Duel.HintSelection(g)
		-- 执行将所选卡片送回玩家手牌的效果处理，并检测是否成功。
		if Duel.SendtoHand(g,nil,REASON_EFFECT)>0
			and g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND)
			and c:IsRelateToChain() and c:IsFaceup() then
			-- 这张卡的攻击力上升2000。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(2000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
