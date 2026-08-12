--マジェスペクター・フロッグ
-- 效果：
-- ←5 【灵摆】 5→
-- 【怪兽效果】
-- 「威风妖怪·蛤蟆」的①的怪兽效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功时才能发动。从卡组选1张「威风妖怪」魔法·陷阱卡在自己场上盖放。这个效果盖放的卡在这个回合不能发动。
-- ②：这张卡只要在怪兽区域存在，不会成为对方的效果的对象，不会被对方的效果破坏。
function c645794.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性（注册灵摆召唤和灵摆卡的发动效果）
	aux.EnablePendulumAttribute(c)
	-- 「威风妖怪·蛤蟆」的①的怪兽效果1回合只能使用1次。①：这张卡召唤·特殊召唤成功时才能发动。从卡组选1张「威风妖怪」魔法·陷阱卡在自己场上盖放。这个效果盖放的卡在这个回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,645794)
	e2:SetTarget(c645794.settg)
	e2:SetOperation(c645794.setop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：这张卡只要在怪兽区域存在，不会成为对方的效果的对象
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置不能成为效果对象的效果过滤函数，使其仅对对方的效果生效
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
	-- 不会被对方的效果破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetRange(LOCATION_MZONE)
	-- 设置不会被效果破坏的效果过滤函数，使其仅对对方的效果生效
	e5:SetValue(aux.indoval)
	c:RegisterEffect(e5)
end
-- 过滤卡组中属于「威风妖怪」且可以盖放的魔法·陷阱卡
function c645794.filter(c)
	return c:IsSetCard(0xd0) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 效果①的发动准备与合法性检测（检查魔陷区是否有空位，以及卡组中是否存在可盖放的「威风妖怪」魔陷）
function c645794.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己卡组中是否存在至少1张满足过滤条件的「威风妖怪」魔法·陷阱卡
		and Duel.IsExistingMatchingCard(c645794.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果①的执行逻辑（从卡组选择一张「威风妖怪」魔陷盖放到场上，并限制其在本回合不能发动）
function c645794.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，再次检查自己场上的魔法与陷阱区域是否有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的「威风妖怪」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c645794.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 若成功选出卡片，则将其在自己场上盖放，并判断是否盖放成功
	if tc and Duel.SSet(tp,tc)~=0 then
		-- 这个效果盖放的卡在这个回合不能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
	end
end
