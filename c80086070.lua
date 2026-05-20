--ベアルクティ－グラン＝シャリオ
-- 效果：
-- 这张卡不能同调召唤，等级差直到7为止从自己场上把8星以上的调整1只和调整以外的同调怪兽1只送去墓地的场合才能特殊召唤。
-- ①：这张卡特殊召唤成功的场合，以这张卡以外的场上最多2张卡为对象才能发动。那些卡破坏。
-- ②：1回合1次，自己场上的「北极天熊」卡为对象的卡的效果发动时，把自己的手卡·场上1只怪兽解放才能发动。那个发动无效。
function c80086070.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能同调召唤，等级差直到7为止从自己场上把8星以上的调整1只和调整以外的同调怪兽1只送去墓地的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 等级差直到7为止从自己场上把8星以上的调整1只和调整以外的同调怪兽1只送去墓地的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(c80086070.sprcon)
	e2:SetTarget(c80086070.sprtg)
	e2:SetOperation(c80086070.sprop)
	c:RegisterEffect(e2)
	-- ①：这张卡特殊召唤成功的场合，以这张卡以外的场上最多2张卡为对象才能发动。那些卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(80086070,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(c80086070.destg)
	e3:SetOperation(c80086070.desop)
	c:RegisterEffect(e3)
	-- ②：1回合1次，自己场上的「北极天熊」卡为对象的卡的效果发动时，把自己的手卡·场上1只怪兽解放才能发动。那个发动无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(80086070,1))
	e4:SetCategory(CATEGORY_NEGATE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c80086070.negcon)
	e4:SetCost(c80086070.negcost)
	e4:SetTarget(c80086070.negtg)
	e4:SetOperation(c80086070.negop)
	c:RegisterEffect(e4)
end
-- 过滤场上表侧表示、等级1以上且可以送去墓地的怪兽（用于特殊召唤的素材判定）
function c80086070.tgrfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(1) and c:IsAbleToGraveAsCost()
end
-- 过滤8星以上的调整怪兽
function c80086070.tgrfilter1(c)
	return c:IsType(TYPE_TUNER) and c:IsLevelAbove(8)
end
-- 过滤调整以外的同调怪兽
function c80086070.tgrfilter2(c)
	return not c:IsType(TYPE_TUNER) and c:IsType(TYPE_SYNCHRO)
end
-- 检查卡片组中是否存在与当前卡片等级差为7的另一张卡
function c80086070.mnfilter(c,g)
	return g:IsExists(c80086070.mnfilter2,1,c,c)
end
-- 检查两张怪兽的等级差是否刚好为7
function c80086070.mnfilter2(c,mc)
	return c:GetLevel()-mc:GetLevel()==7
end
-- 检查选取的2张卡是否满足特殊召唤的素材条件（包含1只8星以上调整、1只非调整同调怪兽、等级差为7，且能腾出额外怪兽区域的空格）
function c80086070.fselect(g,tp,sc)
	return g:GetCount()==2
		and g:IsExists(c80086070.tgrfilter1,1,nil) and g:IsExists(c80086070.tgrfilter2,1,nil)
		and g:IsExists(c80086070.mnfilter,1,nil,g)
		-- 判定将这些素材送去墓地后，额外卡组是否有可用的怪兽区域用于特殊召唤
		and Duel.GetLocationCountFromEx(tp,tp,g,sc)>0
end
-- 特殊召唤规则的条件函数：检查场上是否存在满足特殊召唤素材条件的卡片组合
function c80086070.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上所有满足送墓条件的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c80086070.tgrfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(c80086070.fselect,2,2,tp,c)
end
-- 特殊召唤规则的目标选择函数：让玩家选择用于特殊召唤的2张素材卡，并将其保存在效果对象中
function c80086070.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有满足送墓条件的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c80086070.tgrfilter,tp,LOCATION_MZONE,0,nil)
	-- 给玩家发送“请选择要送去墓地的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c80086070.fselect,true,2,2,tp,c)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的执行函数：将选定的素材送去墓地以完成特殊召唤
function c80086070.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定的素材怪兽作为特殊召唤的消耗送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 效果①（破坏场上卡片）的发动准备函数：选择场上最多2张卡作为破坏对象
function c80086070.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() end
	-- 检查场上是否存在除这张卡以外的至少1张卡可以作为效果对象
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 给玩家发送“请选择要破坏的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上除这张卡以外的1到2张卡作为破坏的对象
	local dg=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,e:GetHandler())
	-- 设置连锁处理的操作信息，表明此效果将破坏选定的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 效果①（破坏场上卡片）的执行函数：破坏所有仍存在于场上且与效果相关的对象卡片
function c80086070.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与该效果相关的对象卡片组
	local dg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #dg>0 then
		-- 因效果将选定的卡片破坏并送去墓地
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
-- 过滤自己场上表侧表示的「北极天熊」卡片
function c80086070.negfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x163) and c:IsOnField() and c:IsControler(tp)
end
-- 效果②（无效发动）的条件函数：检查是否有以自己场上「北极天熊」卡片为对象的效果发动，且该发动可以被无效
function c80086070.negcon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取触发效果的连锁中所选择的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判定对象中是否包含自己场上的「北极天熊」卡，且该发动的效果可以被无效
	return tg and tg:IsExists(c80086070.negfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
-- 过滤可以作为解放代价的怪兽（自己场上或手卡的怪兽，若在场上则必须是表侧表示）
function c80086070.costfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and (c:IsControler(tp) or c:IsFaceup())
end
-- 过滤墓地中具有代替解放效果且可以除外的卡片
function c80086070.excostfilter(c,tp)
	return c:IsAbleToRemove() and (c:IsHasEffect(16471775,tp) or c:IsHasEffect(89264428,tp))
end
-- 效果②（无效发动）的代价函数：解放自己手卡·场上的一只怪兽，或者使用墓地卡片的代替解放效果
function c80086070.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己手卡和场上可用于解放的怪兽卡片组
	local g1=Duel.GetReleaseGroup(tp,true):Filter(c80086070.costfilter,nil,tp)
	-- 获取墓地中可用于代替解放的卡片组
	local g2=Duel.GetMatchingGroup(c80086070.excostfilter,tp,LOCATION_GRAVE,0,nil,tp)
	g1:Merge(g2)
	if chk==0 then return #g1>0 end
	-- 给玩家发送“请选择要解放的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local rg=g1:Select(tp,1,1,nil)
	local tc=rg:GetFirst()
	local te=tc:IsHasEffect(16471775,tp) or tc:IsHasEffect(89264428,tp)
	if te then
		te:UseCountLimit(tp)
		-- 将代替解放的墓地卡片表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
	else
		-- 消耗类似「暗影敌托邦」等卡片的代替解放效果次数
		aux.UseExtraReleaseCount(rg,tp)
		-- 将选定的怪兽解放作为发动的代价
		Duel.Release(tc,REASON_COST)
	end
end
-- 效果②（无效发动）的发动准备函数：设置无效发动的操作信息
function c80086070.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的操作信息，表明此效果将使该发动的效果无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果②（无效发动）的执行函数：使该效果的发动无效
function c80086070.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效指定连锁的发动
	Duel.NegateActivation(ev)
end
