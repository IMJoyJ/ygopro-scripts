--スカイスクレイパー・シュート
-- 效果：
-- ①：以自己场上1只「元素英雄」融合怪兽为对象才能发动。比那只怪兽攻击力高的对方场上的表侧表示怪兽全部破坏。那之后，给与对方这个效果破坏送去墓地的怪兽之内原本攻击力最高的怪兽的那个数值的伤害。自己的场地区域有「摩天楼」场地魔法卡存在的场合，给与对方的伤害变成这个效果破坏送去墓地的怪兽全部的原本攻击力的合计数值。
function c40522482.initial_effect(c)
	-- ①：以自己场上1只「元素英雄」融合怪兽为对象才能发动。比那只怪兽攻击力高的对方场上的表侧表示怪兽全部破坏。那之后，给与对方这个效果破坏送去墓地的怪兽之内原本攻击力最高的怪兽的那个数值的伤害。自己的场地区域有「摩天楼」场地魔法卡存在的场合，给与对方的伤害变成这个效果破坏送去墓地的怪兽全部的原本攻击力的合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c40522482.target)
	e1:SetOperation(c40522482.activate)
	c:RegisterEffect(e1)
end
-- 定义选择对象的过滤函数：筛选自己场上表侧表示、属于「元素英雄」系列且为融合怪兽的怪兽，并且该怪兽的攻击力数值要能作为后续破坏筛选的基准，即对方场上有攻击力高于它的表侧怪兽，否则效果无法发动。
function c40522482.filter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x3008) and c:IsType(TYPE_FUSION)
		-- 追加判定对方场上是否存在至少1张表侧表示且当前攻击力高于对象怪兽当前攻击力的怪兽，作为效果发动的前提条件。
		and Duel.IsExistingMatchingCard(c40522482.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack())
end
-- 定义“攻击力高于指定数值”的筛选条件：对方场上表侧表示且当前攻击力大于atk的怪兽。
function c40522482.desfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()>atk
end
-- 效果发动时的目标与操作信息设定流程：选择己方场上1只符合条件的「元素英雄」融合怪兽为对象，以该怪兽当前攻击力为基准检索对方场上的表侧高攻怪兽并设置破坏信息；再根据场地区是否存在表侧「摩天楼」计算伤害数值（合计原本攻击力或最高原本攻击力），设置伤害信息。
function c40522482.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c40522482.filter(chkc,tp) end
	-- 在发动合法性检查阶段，确认己方场上存在至少1只可以成为对象的符合条件的「元素英雄」融合怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c40522482.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 向操作玩家显示选择效果对象的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上符合条件的「元素英雄」融合怪兽中选择1只作为效果对象，并将其与当前连锁关联。
	local tg=Duel.SelectTarget(tp,c40522482.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local atk=tg:GetFirst():GetAttack()
	-- 以对象怪兽的当前攻击力为基准，检索对方场上所有表侧表示且攻击力高于该数值的怪兽，作为预定的破坏候选集合。
	local g=Duel.GetMatchingGroup(c40522482.desfilter,tp,0,LOCATION_MZONE,nil,atk)
	-- 设置当前连锁的破坏操作信息：破坏对象为检索到的怪兽集合，数量为该集合的卡数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 取得己方场地区域第0格的卡，用于判断是否有「摩天楼」场地魔法卡存在。
	local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	local dam=0
	if fc and c40522482.ffilter(fc) then
		dam=g:GetSum(Card.GetBaseAttack)
	else
		g,dam=g:GetMaxGroup(Card.GetBaseAttack)
	end
	-- 设置当前连锁的伤害操作信息：对对方造成预计dam点伤害；因实际伤害对象在效果处理时才确定，目标集合暂时为空。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,1,1-tp,dam)
end
-- 定义「摩天楼」的判定函数：该卡为表侧表示且属于0xf6（摩天楼）。
function c40522482.ffilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf6)
end
-- 效果处理时执行的实际操作：获取对象怪兽并确认其仍与效果关联且非里侧；重新检索对方场上表侧且攻击力高于对象当前攻击力的怪兽并全部破坏；从被破坏且进入墓地的怪兽中，根据场地区是否有表侧「摩天楼」，选择原本攻击力合计值或最高原本攻击力值，对对方造成伤害。
function c40522482.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 在效果处理时重新检索对方场上所有表侧表示且当前攻击力高于对象怪兽当前攻击力的怪兽，作为实际要破坏的集合。
	local g=Duel.GetMatchingGroup(c40522482.desfilter,tp,0,LOCATION_MZONE,nil,tc:GetAttack())
	-- 存在符合条件的怪兽时，将它们全部以效果原因破坏；仅当实际破坏数量大于0时继续后续伤害处理。
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		-- 取得刚才破坏操作实际处理的卡片，并筛选出其中目前位于墓地的怪兽，用于计算应给予的伤害。
		local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE)
		if og:GetCount()==0 then return end
		-- 取得己方场地区第0格的卡，再次确认是否存在「摩天楼」，以决定伤害计算方式。
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		local dam=0
		if fc and c40522482.ffilter(fc) then
			dam=og:GetSum(Card.GetBaseAttack)
		else
			g,dam=og:GetMaxGroup(Card.GetBaseAttack)
		end
		if dam>0 then
			-- 中断当前效果处理，使后续伤害处理与破坏处理视为不同时点，以便正确触发相关时点效果。
			Duel.BreakEffect()
			-- 以效果原因对对方玩家造成dam点伤害，对应效果原文中“给与对方……伤害”的部分。
			Duel.Damage(1-tp,dam,REASON_EFFECT)
		end
	end
end
