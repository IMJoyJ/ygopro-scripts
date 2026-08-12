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
-- 初始化函数：设定连接召唤手续并注册3个效果——e1为连接召唤成功时以自己墓地1张速攻魔法卡为对象盖放的诱发选发效果（1回合1次），e2为使双方场地区域的卡不会成为对方效果对象的永续效果，e3为这张卡被破坏时根据场地区域卡的数量适用破坏或伤害效果的诱发选发效果（1回合1次）
function s.initial_effect(c)
	-- 设定连接召唤手续：用2只光属性怪兽作为连接素材，且素材中必须包含兽族怪兽（由s.lcheck检查）
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_LIGHT),2,2,s.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合，以自己墓地1张速攻魔法卡为对象才能发动。那张卡在自己场上盖放。（这个卡名的①的效果1回合只能使用1次）
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
	-- ②：对方不能把场地区域的卡作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_FZONE,LOCATION_FZONE)
	-- 设定效果判定：只有对方玩家发动的效果不能把场地区域的卡作为对象（自己发动的效果不受影响）
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ③：这张卡被破坏的场合才能发动。选最多有场地区域的卡数量的以下效果，那些效果适用（相同效果最多1个）。●对方场上1张卡破坏。●给与对方1500伤害。（这个卡名的③的效果1回合只能使用1次）
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
-- 连接素材的附加检查：素材组中必须存在至少1只兽族怪兽
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkRace,1,nil,RACE_BEAST)
end
-- 发动条件检查：这张卡必须是连接召唤成功的场合才能发动
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 对象卡的过滤条件：是速攻魔法卡且可以在场上盖放
function s.setfilter(c)
	return c:IsType(TYPE_QUICKPLAY) and c:IsSSetable()
end
-- e1的对象选择处理：发动条件为确认自己墓地存在可成为对象的速攻魔法卡，发动时选择自己墓地1张速攻魔法卡为对象，并设置将那张卡离开墓地的操作信息
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.setfilter(chkc) end
	-- 发动条件检查：自己墓地存在至少1张可成为效果对象的速攻魔法卡
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家「请选择要盖放的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 以自己墓地1张速攻魔法卡为对象并将其设置为当前连锁的对象
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：宣告将把1张卡从墓地移出（盖放）
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- e1的效果处理：取得对象卡，若该卡仍与连锁关联且不受「王家长眠之谷」影响，则将那张卡在自己场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡仍然存在、仍与连锁关联且不受「王家长眠之谷」的影响
	if tc and tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将对象的速攻魔法卡在自己场上盖放
		Duel.SSet(tp,tc)
	end
end
-- e3的对象设置处理：计算双方场地区域的卡数量，发动条件为场地区域至少有1张卡；若对方场上没有卡（无法选择破坏效果），则预先设置给与对方1500伤害的操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算双方场地区域的卡的数量
	local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_FZONE,LOCATION_FZONE,nil)
	if chk==0 then return ct>0 end
	-- 检查对方场上是否存在卡（决定破坏效果是否可以选择）
	if not Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) then
		-- 设置操作信息：宣告将给与对方1500伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1500)
	end
end
-- e3的效果处理：重新计算场地区域的卡数量，让发动玩家从「对方场上1张卡破坏」「给与对方1500伤害」中选择最多相当于场地区域卡数量的效果（场地区域有2张时可选两方），然后依次执行破坏对方场上1张卡和给与对方1500伤害的处理
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新计算双方场地区域的卡的数量（决定最多可选的效果个数）
	local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_FZONE,LOCATION_FZONE,nil)
	if ct==0 then return end
	-- 检查对方场上是否存在卡，作为「破坏」选项是否可选的判定
	local b1=Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
	local op=0
	-- 让发动玩家从可适用的选项中选择要适用的效果：对方场上1张卡破坏、给与对方1500伤害、（场地区域有2张卡且对方场上有卡时）两方都适用
	op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,1),1},  --"对方场上1张卡破坏"
		{true,aux.Stringid(id,2),2},  --"给与对方1500伤害"
		{b1 and ct==2,aux.Stringid(id,3),3})  --"适用两方效果"
	if op&1~=0 then
		-- 提示玩家「请选择要破坏的卡」
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择对方场上1张要破坏的卡
		local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
			-- 显示所选的卡并记录这些卡被选为破坏对象
			Duel.HintSelection(g)
			-- 将选择的对方场上1张卡以效果破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
	if op&2~=0 then
		if op==3 then
			-- 中断当前效果处理，使之后的伤害处理视为不同时进行（避免错时点）
			Duel.BreakEffect()
		end
		-- 以效果给与对方1500伤害
		Duel.Damage(1-tp,1500,REASON_EFFECT)
	end
end
