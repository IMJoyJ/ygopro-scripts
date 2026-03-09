--うかのみつねのおなり
-- 效果：
-- 包含兽族怪兽的光属性怪兽2只
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合，以自己墓地1张速攻魔法卡为对象才能发动。那张卡在自己场上盖放。
-- ②：对方不能把场地区域的卡作为效果的对象。
-- ③：这张卡被破坏的场合才能发动。选最多有场地区域的卡数量的以下效果，那些效果适用（相同效果最多1个）。
-- ●对方场上1张卡破坏。
-- ●给与对方1500伤害。
local s,id,o=GetID()
-- 初始化效果，设置连接召唤条件、启用复活限制并注册三个效果
function s.initial_effect(c)
	-- 添加连接召唤手续，要求使用至少2只光属性怪兽作为素材，并且其中至少1只为兽族
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_LIGHT),2,2,s.lcheck)
	c:EnableReviveLimit()
	-- 效果①：这张卡连接召唤的场合才能发动。以自己墓地1张速攻魔法卡为对象才能发动。那张卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"盖放"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_SSET)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.setcon)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	-- 效果②：对方不能把场地区域的卡作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_FZONE,LOCATION_FZONE)
	-- 设置效果②的目标为场地区域的卡，且该效果不会被免疫
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 效果③：这张卡被破坏的场合才能发动。选最多有场地区域的卡数量的以下效果，那些效果适用（相同效果最多1个）。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 连接召唤时必须满足的条件函数，确保至少有一只兽族怪兽参与连接召唤
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkRace,1,nil,RACE_BEAST)
end
-- 判断是否为连接召唤成功触发的效果
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 筛选墓地中的速攻魔法卡的过滤函数
function s.setfilter(c)
	return c:IsType(TYPE_QUICKPLAY) and c:IsSSetable()
end
-- 设置效果①的目标选择逻辑，提示玩家选择一张墓地中的速攻魔法卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.setfilter(chkc) end
	-- 检查是否有满足条件的墓地速攻魔法卡可供选择
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送提示信息，提示其选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从玩家墓地中选择一张速攻魔法卡作为目标
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，记录将要盖放的卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 执行效果①的操作，将选中的速攻魔法卡盖放在场上
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为目标的卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否仍然存在于连锁中且未受王家长眠之谷影响
	if tc and tc:IsRelateToChain() and aux.NecroValleyFilter(tc) then
		-- 将目标卡盖放在场上
		Duel.SSet(tp,tc)
	end
end
-- 设置效果③的目标选择逻辑，计算场地区域卡的数量并决定是否造成伤害
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场地区域的卡数量
	local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_FZONE,LOCATION_FZONE,nil)
	if chk==0 then return ct>0 end
	-- 检查对方场上是否存在可破坏的卡
	if not Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) then
		-- 设置操作信息，记录将要对对方造成1500伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1500)
	end
end
-- 执行效果③的操作，根据选择的效果对对方进行破坏或造成伤害
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场地区域的卡数量
	local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_FZONE,LOCATION_FZONE,nil)
	if ct==0 then return end
	-- 判断对方场上是否存在可破坏的卡
	local b1=Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
	local op=0
	-- 让玩家从选项中选择一个效果
	op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,1),1},  --"对方场上1张卡破坏"
		{true,aux.Stringid(id,2),2},  --"给与对方1500伤害"
		{b1 and ct==2,aux.Stringid(id,3),3})  --"适用两方效果"
	if op&1~=0 then
		-- 向玩家发送提示信息，提示其选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从对方场上选择一张卡作为破坏目标
		local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
			-- 手动显示被选为对象的动画效果
			Duel.HintSelection(g)
			-- 将选中的卡破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
	if op&2~=0 then
		if op==3 then
			-- 中断当前效果，使之后的效果处理视为不同时处理
			Duel.BreakEffect()
		end
		-- 对对方造成1500伤害
		Duel.Damage(1-tp,1500,REASON_EFFECT)
	end
end
