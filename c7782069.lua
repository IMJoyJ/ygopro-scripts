--剛鬼ザ・タイラント・オーガ
-- 效果：
-- 「刚鬼」连接怪兽＋战士族·恐龙族·电子界族怪兽
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡融合召唤的场合，以最多有那些作为融合素材的「刚鬼」连接怪兽的连接标记合计数量的场上的卡为对象才能发动（连接3以上的怪兽为融合素材的场合，不能对应这个发动把作为对象的卡的效果发动）。那些卡破坏。
-- ②：这张卡进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
local s,id,o=GetID()
-- 初始化卡片效果，注册融合召唤手续、素材检查效果、融合召唤成功时破坏场上卡片的效果以及战斗时限制对方发动效果的永续效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤素材为1只「刚鬼」连接怪兽和1只战士族/恐龙族/电子界族怪兽。
	aux.AddFusionProcFun2(c,s.matfilter1,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR+RACE_DINOSAUR+RACE_CYBERSE),true)
	-- 那些作为融合素材的「刚鬼」连接怪兽的连接标记合计数量
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.matcheck)
	c:RegisterEffect(e0)
	-- ①：这张卡融合召唤的场合，以最多有那些作为融合素材的「刚鬼」连接怪兽的连接标记合计数量的场上的卡为对象才能发动（连接3以上的怪兽为融合素材的场合，不能对应这个发动把作为对象的卡的效果发动）。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	e1:SetLabelObject(e0)
	c:RegisterEffect(e1)
	-- ②：这张卡进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(1)
	e2:SetCondition(s.actcon)
	c:RegisterEffect(e2)
end
-- 过滤作为融合素材的「刚鬼」连接怪兽。
function s.matfilter1(c)
	return c:IsFusionType(TYPE_LINK) and c:IsFusionSetCard(0xfc)
end
-- 检查融合素材，计算作为素材的「刚鬼」连接怪兽的连接标记合计数量，并检测是否存在连接3以上的怪兽作为素材。
function s.matcheck(e,c)
	local ct=c:GetMaterial():Filter(Card.IsFusionSetCard,nil,0xfc):GetSum(Card.GetLink)
	local lim=0
	if c:GetMaterial():IsExists(s.limfilter,1,nil) then
		lim=1
	end
	e:SetLabel(ct,lim)
end
-- 过滤连接标记在3以上的怪兽。
function s.limfilter(c)
	return c:IsLinkAbove(3)
end
-- 触发条件：这张卡融合召唤成功。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 破坏效果的发动准备，获取素材的连接标记合计数量并检查场上是否存在可选择的对象。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	local ct,lim=e:GetLabelObject():GetLabel()
	if chk==0 then return ct>0
		-- 检查场上是否存在至少1张可以作为对象的卡。
		and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择最多等同于素材连接标记合计数量的场上的卡作为对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	-- 设置破坏操作的信息，包含被选为对象的卡片组及其数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	if lim>0 then
		g:KeepAlive()
		-- 设定连锁限制，使对方不能对应这个发动把作为对象的卡的效果发动。
		Duel.SetChainLimit(s.limit(g))
		-- （连接3以上的怪兽为融合素材的场合，不能对应这个发动把作为对象的卡的效果发动）。那些卡破坏。②：这张卡进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(RESET_CHAIN)
		e1:SetCountLimit(1)
		e1:SetLabelObject(g)
		e1:SetOperation(s.retop)
		e1:SetReset(RESET_CHAIN)
		-- 注册用于在连锁结束时清理卡片组缓存的单次性时点效果。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 连锁限制的具体条件：不能发动作为对象的卡的效果。
function s.limit(g)
	return  function (e,lp,tp)
				return not g:IsContains(e:GetHandler())
			end
end
-- 连锁结束时，删除保存的对象卡片组，释放内存。
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():DeleteGroup()
end
-- 破坏效果的处理：获取成为对象的卡，并将其破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与该效果关联的对象卡片。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToChain,nil)
	-- 将这些卡因效果破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
-- 限制发动效果的条件：这张卡进行战斗的场合（自身是攻击怪兽或被攻击怪兽）。
function s.actcon(e)
	-- 检查当前进行战斗的怪兽是否为这张卡自身。
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
