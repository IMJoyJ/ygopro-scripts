--E・HERO コスモ・ネオス
-- 效果：
-- 「元素英雄 新宇侠」＋属性不同的「新空间侠」怪兽×3
-- 让自己场上的上记卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。
-- ①：这张卡从额外卡组的特殊召唤成功的场合才能发动。这个回合对方不能把场上发动的效果发动。对方不能对应这个效果的发动把魔法·陷阱·怪兽的效果发动。
-- ②：结束阶段发动。这张卡回到额外卡组，对方场上的卡全部破坏。
function c90050480.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合素材为「元素英雄 新宇侠」加上3只属性不同的「新空间侠」怪兽
	aux.AddFusionProcCodeFun(c,89943723,c90050480.ffilter,3,true,true)
	-- 添加接触融合召唤手续，要求将自己场上的素材卡回到卡组
	aux.AddContactFusionProcedure(c,Card.IsAbleToDeckOrExtraAsCost,LOCATION_ONFIELD,0,aux.ContactFusionSendToDeck(c))
	-- 让自己场上的上记卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(c90050480.splimit)
	c:RegisterEffect(e1)
	-- 注册「新宇」系列怪兽共通的结束阶段返回额外卡组效果
	aux.EnableNeosReturn(c,c90050480.retop,c90050480.set_category)
	-- ①：这张卡从额外卡组的特殊召唤成功的场合才能发动。这个回合对方不能把场上发动的效果发动。对方不能对应这个效果的发动把魔法·陷阱·怪兽的效果发动。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(90050480,1))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCondition(c90050480.limcon)
	e5:SetTarget(c90050480.limtg)
	e5:SetOperation(c90050480.limop)
	c:RegisterEffect(e5)
end
c90050480.material_setcode=0x8
-- 融合素材过滤：必须是怪兽，属于「新空间侠」系列，且不能与已选素材的属性相同
function c90050480.ffilter(c,fc,sub,mg,sg)
	return c:IsType(TYPE_MONSTER) and c:IsFusionSetCard(0x1f) and (not sg or not sg:Filter(Card.IsFusionSetCard,nil,0x1f):IsExists(Card.IsFusionAttribute,1,c,c:GetFusionAttribute()))
end
-- 特殊召唤限制：若此卡在额外卡组，则不能进行通常的特殊召唤
function c90050480.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- 设置结束阶段效果的分类为回卡组和破坏，并设置破坏对方场上所有卡的操作信息
function c90050480.set_category(e,tp,eg,ep,ev,re,r,rp)
	e:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY)
	-- 获取对方场上的所有卡（不包括自身）
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,e:GetHandler())
	-- 设置操作信息：预计破坏对方场上的所有卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 结束阶段效果的具体执行：将自身送回额外卡组，若成功送回，则破坏对方场上的所有卡
function c90050480.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身送回额外卡组并洗牌
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	if c:IsLocation(LOCATION_EXTRA) then
		-- 获取对方场上的所有卡
		local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
		-- 因效果破坏对方场上的所有卡
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 效果①的发动条件：此卡必须是从额外卡组特殊召唤成功
function c90050480.limcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_EXTRA)
end
-- 效果①的发动准备：设置连锁限制，使对方不能对应此效果的发动来发动任何卡的效果
function c90050480.limtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 限制连锁，使对方不能对应此效果的发动来发动魔法、陷阱、怪兽的效果
	Duel.SetChainLimit(c90050480.chainlm)
end
-- 连锁限制判定：只有发动玩家可以继续连锁，即对方不能进行连锁
function c90050480.chainlm(e,rp,tp)
	return tp==rp
end
-- 效果①的具体执行：注册一个持续到回合结束的全局效果，使对方不能发动场上的卡的效果
function c90050480.limop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合对方不能把场上发动的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(c90050480.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制对方发动场上效果的永续效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制发动效果的判定：限制在场上发动的效果，以及魔法·陷阱卡的卡片发动
function c90050480.aclimit(e,re,tp)
	return re:GetHandler():IsOnField() or re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
