--星杯の守護竜アルマドゥーク
-- 效果：
-- 连接怪兽×3
-- 这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。
-- ●把自己场上的上记卡解放的场合可以从额外卡组特殊召唤（不需要「融合」）。
-- ①：这张卡可以向对方怪兽全部各作1次攻击。
-- ②：这张卡和对方的连接怪兽进行战斗的攻击宣言时，把连接标记数量和那只对方怪兽相同的1只连接怪兽从自己的场上·墓地除外才能发动。那只对方怪兽破坏，给与对方那个原本攻击力数值的伤害。
function c95793022.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤素材为3只连接怪兽
	aux.AddFusionProcFunRep(c,c95793022.ffilter,3,true)
	-- 添加接触融合特殊召唤手续：将自己场上的上述卡解放
	aux.AddContactFusionProcedure(c,aux.FilterBoolFunction(Card.IsReleasable,REASON_SPSUMMON),LOCATION_MZONE,0,Duel.Release,REASON_SPSUMMON+REASON_MATERIAL)
	-- 这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c95793022.splimit)
	c:RegisterEffect(e1)
	-- ①：这张卡可以向对方怪兽全部各作1次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_ATTACK_ALL)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ②：这张卡和对方的连接怪兽进行战斗的攻击宣言时，把连接标记数量和那只对方怪兽相同的1只连接怪兽从自己的场上·墓地除外才能发动。那只对方怪兽破坏，给与对方那个原本攻击力数值的伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(95793022,0))
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c95793022.atkcon)
	e4:SetCost(c95793022.atkcost)
	e4:SetTarget(c95793022.atktg)
	e4:SetOperation(c95793022.atkop)
	c:RegisterEffect(e4)
end
-- 融合素材过滤：连接怪兽
function c95793022.ffilter(c)
	return c:IsFusionType(TYPE_LINK)
end
-- 特殊召唤限制函数：在额外卡组时只能通过融合召唤或自身特召协定特殊召唤
function c95793022.splimit(e,se,sp,st)
	-- 若不在额外卡组则不受限，若在额外卡组则必须符合融合召唤（或接触融合）规则
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st)
end
-- 效果②的发动条件：这张卡与对方场上表侧表示的连接怪兽进行战斗的攻击宣言时
function c95793022.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	e:SetLabelObject(tc)
	return tc and tc:IsFaceup() and tc:IsControler(1-tp) and tc:IsType(TYPE_LINK)
end
-- 效果②的Cost过滤：自己场上或墓地中，连接标记数量与对方怪兽相同且可以除外的连接怪兽
function c95793022.cfilter(c,lk)
	return c:IsType(TYPE_LINK) and c:IsLink(lk) and c:IsAbleToRemoveAsCost()
end
-- 效果②的发动代价：从自己的场上·墓地将1只连接标记数量与对方怪兽相同的连接怪兽除外
function c95793022.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject()
	-- 检查自己场上或墓地是否存在满足除外条件的连接怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c95793022.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tc:GetLink()) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择1只满足条件的连接怪兽
	local g=Duel.SelectMatchingCard(tp,c95793022.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tc:GetLink())
	-- 将选中的怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的靶向与效果注册：注册破坏对方怪兽并给予伤害的操作信息
function c95793022.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=e:GetLabelObject()
	-- 设置破坏对方怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	-- 设置给予对方其原本攻击力数值伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,tc:GetBaseAttack())
end
-- 效果②的效果处理：破坏对方怪兽，并给予对方其原本攻击力数值的伤害
function c95793022.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local dam=tc:GetBaseAttack()
	-- 检查对方怪兽是否仍处于战斗状态且由对方控制，若成功破坏该怪兽且其原本攻击力大于0
	if tc:IsRelateToBattle() and tc:IsControler(1-tp) and Duel.Destroy(tc,REASON_EFFECT)~=0 and dam>0 then
		-- 给予对方该怪兽原本攻击力数值的伤害
		Duel.Damage(1-tp,dam,REASON_EFFECT)
	end
end
