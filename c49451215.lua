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
-- 初始化函数：设定连接召唤手续（2只光属性怪兽且包含兽族怪兽），并注册三个效果：e1为连接召唤成功时把墓地速攻魔法盖放的诱发取对象效果（1回合1次），e2为使双方场地区域的卡不能成为对方效果对象的永续效果，e3为被破坏时按场地区域卡数量选择破坏或伤害效果的诱发效果（1回合1次）
function s.initial_effect(c)
	-- 为这张卡添加连接召唤手续：以2只光属性怪兽作为连接素材，且素材组合需满足s.lcheck（包含兽族怪兽）
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_LIGHT),2,2,s.lcheck)
	c:EnableReviveLimit()
	-- 这个卡名的①③的效果1回合各能使用1次。①：这张卡连接召唤的场合，以自己墓地1张速攻魔法卡为对象才能发动。那张卡在自己场上盖放。
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
	-- 设定该永续效果的判定值：只有以这张卡控制者来看是对方（即效果使用者为对方玩家）时才适用，使场地区域的卡不会成为对方效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 这个卡名的①③的效果1回合各能使用1次。③：这张卡被破坏的场合才能发动。选最多有场地区域的卡数量的以下效果，那些效果适用（相同效果最多1个）。●对方场上1张卡破坏。●给与对方1500伤害。
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
-- 连接素材检查函数：确认这组连接素材中至少存在1只兽族怪兽
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkRace,1,nil,RACE_BEAST)
end
-- ①效果的发动条件：这张卡是连接召唤成功的场合
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 对象过滤函数：这张卡是速攻魔法卡且可以在场上盖放
function s.setfilter(c)
	return c:IsType(TYPE_QUICKPLAY) and c:IsSSetable()
end
-- ①效果的对象设定：已在连锁上指定的对象需为自己墓地的可盖放速攻魔法；发动时检查自己墓地是否存在可作为对象的速攻魔法卡，然后让玩家选择1张作为对象并设置离开墓地的操作信息
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.setfilter(chkc) end
	-- 发动可行性检查：自己墓地是否存在至少1张可以作为此效果对象的速攻魔法卡
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示选择提示“请选择要盖放的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从自己墓地选择1张速攻魔法卡作为此效果的对象
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：确定有1张卡将作为此效果的处理对象离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ①效果的处理：取得对象卡，若其仍与当前连锁关联且不受王家长眠之谷影响，则把那张卡在自己场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的第1个对象卡
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡仍然存在、仍与当前连锁关联，且不受王家长眠之谷的影响
	if tc and tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 把对象的那张速攻魔法卡在自己场上盖放
		Duel.SSet(tp,tc)
	end
end
-- ③效果的对象设定：统计双方场地区域的卡数量，发动时需场地区域至少有1张卡；若对方场上没有卡（无法选择破坏效果），则预先设置给与对方1500伤害的操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计双方场地区域的卡数量，作为可选择的效果个数上限
	local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_FZONE,LOCATION_FZONE,nil)
	if chk==0 then return ct>0 end
	-- 检查对方场上是否不存在任何卡（即“对方场上1张卡破坏”这一选项是否不可用）
	if not Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) then
		-- 设置操作信息：此效果处理时将给与对方1500伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1500)
	end
end
-- ③效果的处理：统计场地区域的卡数量，为0则不处理；判断对方场上是否有卡以决定“破坏”选项是否可用，然后让玩家从“对方场上1张卡破坏”“给与对方1500伤害”“两方都适用”（需场地区域2张卡且对方场上有卡）中选择；选了破坏则选择对方场上1张卡破坏，选了伤害则给与对方1500伤害，两方都适用时先中断效果再造成伤害以避免错时点问题
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新统计双方场地区域的卡数量，为0张则直接结束处理
	local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_FZONE,LOCATION_FZONE,nil)
	if ct==0 then return end
	-- 检查对方场上是否存在至少1张卡，作为“破坏”选项是否可选的标记
	local b1=Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
	local op=0
	-- 让玩家从可用选项中选择要适用的效果：对方场上1张卡破坏／给与对方1500伤害／两方效果都适用
	op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,1),1},  --"对方场上1张卡破坏"
		{true,aux.Stringid(id,2),2},  --"给与对方1500伤害"
		{b1 and ct==2,aux.Stringid(id,3),3})  --"适用两方效果"
	if op&1~=0 then
		-- 向玩家显示选择提示“请选择要破坏的卡”
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让玩家选择对方场上1张要破坏的卡
		local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
			-- 显示所选卡的选中动画并记录这些卡被选择
			Duel.HintSelection(g)
			-- 以效果原因破坏选择的那张卡
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
	if op&2~=0 then
		if op==3 then
			-- 中断当前效果处理，使之后的伤害处理与前面的破坏不视为同时处理（会造成错时点）
			Duel.BreakEffect()
		end
		-- 以效果原因给与对方1500伤害
		Duel.Damage(1-tp,1500,REASON_EFFECT)
	end
end
