--反逆の罪宝－スネークアイ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以场上1只表侧表示怪兽为对象才能发动。那只怪兽当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置。
local s,id,o=GetID()
-- 创建并注册这张卡的①效果：在自由时点发动，取对象，1回合只能发动1次（誓约次数），指定场上1只表侧表示怪兽为对象，发动后将其放置到原本持有者的魔陷区并变为永续魔法。
function s.initial_effect(c)
	-- 对应效果原文“这个卡名的卡在1回合只能发动1张。①：以场上1只表侧表示怪兽为对象才能发动。那只怪兽当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义目标筛选函数：目标必须是表侧表示怪兽，且其原本持有者的魔陷区必须有足够空格；若目标持有者不是发动玩家则无需考虑发动玩家魔陷区的占用；若目标控制权与持有权不一致，还要求目标能够改变控制权。
function s.filter(c,tp,ft)
	if c:IsFacedown() then return false end
	local p=c:GetOwner()
	if p~=tp then ft=0 end
	local r=LOCATION_REASON_TOFIELD
	if not c:IsControler(p) then
		if not c:IsAbleToChangeControler() then return false end
		r=LOCATION_REASON_CONTROL
	end
	-- 检查目标怪兽原本持有者的魔陷区可用空格数是否大于ft（ft为0或1），以确保有足够位置放置变成魔法卡的怪兽。
	return Duel.GetLocationCount(p,LOCATION_SZONE,tp,r)>ft
end
-- 目标选定流程：若在连锁中指定对象则验证其位于怪兽区且满足筛选条件；若为发动时的合法性检查，则检查场上是否存在至少1只满足条件的表侧表示怪兽，并提示玩家选择表侧表示怪兽后选定1只作为效果对象。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,tp,0) end
	if chk==0 then
		local ft=e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetHandler():IsLocation(LOCATION_HAND) and 1 or 0
		-- 发动时确认场上是否存在至少1只可以成为对象的表侧表示怪兽，且满足空格数与控制权等条件。
		return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp,ft)
	end
	-- 向发动玩家显示“请选择表侧表示的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让发动玩家从双方怪兽区域选择1只满足条件的表侧表示怪兽，将其登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp,0)
end
-- 效果处理：取得对象怪兽，确认其仍与效果有关联且不免疫此效果后，将其移动到其原本持有者的魔陷区表侧放置，并附加一个不可无效的“种类变为永续魔法”的效果。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e)
		-- 满足条件时，由发动玩家将对象怪兽移动到其原本持有者的魔法与陷阱区域，以表侧表示放置，并立即适用该怪兽作为魔法卡的效果。
		and Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true) then
		-- 对应效果原文“那只怪兽当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置。”实际代码为给移动后的怪兽注册EFFECT_CHANGE_TYPE，将其种类变为魔法卡与永续魔法。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
