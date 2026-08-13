--蛇眼の大炎魔
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡和对方怪兽进行战斗的攻击宣言时才能发动。那只对方怪兽和这张卡各当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置。
-- ②：这张卡是当作永续魔法卡使用的场合，以「蛇眼大炎魔」以外的自己墓地1只炎属性怪兽为对象才能发动。那只怪兽当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置，这张卡特殊召唤。
local s,id,o=GetID()
-- 为这张卡注册效果①和效果②（这个卡名的①②效果1回合各能使用1次）：①攻击宣言时，将战斗的对方怪兽和这张卡各自当作永续魔法卡放置到原本持有者的魔陷区；②当作永续魔法卡使用时，以墓地其他炎属性怪兽为对象，将其放置到原本持有者的魔陷区并将这张卡特殊召唤。
function s.initial_effect(c)
	-- ①：这张卡和对方怪兽进行战斗的攻击宣言时才能发动。那只对方怪兽和这张卡各当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"放置到魔法与陷阱区域"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.mvcon)
	e1:SetTarget(s.mvtg)
	e1:SetOperation(s.mvop)
	c:RegisterEffect(e1)
	-- ②：这张卡是当作永续魔法卡使用的场合，以「蛇眼大炎魔」以外的自己墓地1只炎属性怪兽为对象才能发动。那只怪兽当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置，这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.mvcon2)
	e2:SetTarget(s.mvtg2)
	e2:SetOperation(s.mvop2)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：这张卡与对方怪兽进行战斗（攻击宣言时），战斗对象为对方控制；同时按这张卡和战斗对象各自的原持有者，计算需要占用己方/对方魔陷区的空格数，只有双方魔陷区空格都足够时才可发动。
function s.mvcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ac=c:GetBattleTarget()
	local ft1=0
	local ft2=0
	if c:GetOwner()==tp then
		ft1=ft1+1
	else
		ft2=ft2+1
	end
	if ac and ac:GetOwner()==tp then
		ft1=ft1+1
	else
		ft2=ft2+1
	end
	-- 判定存在战斗对象且该对象由对方控制，并且己方魔陷区剩余空格不少于应放置在己方区的卡数（ft1）。
	return ac and ac:IsControler(1-tp) and Duel.GetLocationCount(tp,LOCATION_SZONE)>=ft1
		-- 判定对方魔陷区剩余空格不少于应放置在对方区的卡数（ft2），保证两张卡都能放到各自原本持有者的魔陷区。
		and Duel.GetLocationCount(1-tp,LOCATION_SZONE)>=ft2
end
-- 效果①发动时，确认这张卡存在战斗对象，并将该战斗对象登记为当前连锁的关联对象，以便效果处理时取得。
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ac=c:GetBattleTarget()
	if chk==0 then return ac~=nil end
	-- 将战斗对象设置为当前连锁的关联对象，效果处理时可通过 Duel.GetFirstTarget 取得该对象。
	Duel.SetTargetCard(ac)
end
-- 效果①处理时，先进行合法性检查：战斗对象与本卡仍与效果关联、均未被战斗破坏确定、对象仍为对方控制，且双方魔陷区空格仍足够，否则效果不处理。
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取出效果发动时登记的战斗对象。
	local ac=Duel.GetFirstTarget()
	if not ac:IsRelateToEffect(e) or not c:IsRelateToEffect(e) or ac:IsStatus(STATUS_BATTLE_DESTROYED) or c:IsStatus(STATUS_BATTLE_DESTROYED) or not ac:IsControler(1-tp) then return false end
	local ft1=0
	local ft2=0
	if c:GetOwner()==tp then
		ft1=ft1+1
	else
		ft2=ft2+1
	end
	if ac and ac:GetOwner()==tp then
		ft1=ft1+1
	else
		ft2=ft2+1
	end
	-- 若己方魔陷区可用空格不足以容纳原持有者为己方的那张卡，则不进行后续处理。
	if not (Duel.GetLocationCount(tp,LOCATION_SZONE)>=ft1)
		-- 若对方魔陷区可用空格不足以容纳原持有者为对方的那张卡，则同样不处理；该检查确保两张卡能同时放置。
		or not (Duel.GetLocationCount(1-tp,LOCATION_SZONE)>=ft2) then return false end
	if not ac:IsControler(1-tp) then return false end
	if ac:IsType(TYPE_MONSTER) and not ac:IsImmuneToEffect(e)
		-- 若战斗对象是怪兽且不免疫此效果，则由发动玩家将其移动至其原持有者的魔陷区，表侧表示放置，并立即适用效果。
		and Duel.MoveToField(ac,tp,ac:GetOwner(),LOCATION_SZONE,POS_FACEUP,true) then
		-- 那只对方怪兽当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		ac:RegisterEffect(e1)
	end
	if not c:IsImmuneToEffect(e)
		-- 若这张卡不免疫此效果，则由发动玩家将其移动至其原本持有者的魔陷区，表侧表示放置，并立即适用效果。
		and Duel.MoveToField(c,tp,c:GetOwner(),LOCATION_SZONE,POS_FACEUP,true) then
		-- 这张卡当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
	end
end
-- 效果②的发动条件：这张卡处于魔法与陷阱区域且当作永续魔法卡使用（同时具有魔法和永续属性）。
function s.mvcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS)
end
-- 效果②选择对象的过滤条件：对象必须是「蛇眼大炎魔」以外的炎属性怪兽、位于自己墓地，且己方魔陷区有空位可以放置该对象。
function s.filter2(c,tp)
	return not c:IsCode(id) and c:IsAttribute(ATTRIBUTE_FIRE)
		-- 过滤条件之一：当前己方魔陷区必须仍有空位，以容纳作为永续魔法卡放置的对象。
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
end
-- 效果②发动时：在对象合法性确认分支中检查对象仍在墓地且满足条件；在发动判定时确认墓地存在可选择的炎属性怪兽、己方怪兽区有空位、且这张卡本身可以特殊召唤，随后选择对象并设置操作信息。
function s.mvtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.filter2(chkc,tp) end
	-- 发动合法性检查时，确认自己墓地存在至少1只满足条件的炎属性怪兽可以成为效果对象。
	if chk==0 then return Duel.IsExistingTarget(s.filter2,tp,LOCATION_GRAVE,0,1,nil,tp)
		-- 并且确认己方怪兽区有空位，用于之后特殊召唤这张卡。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向发动玩家显示『请选择效果的对象』的提示，为选择墓地炎属性怪兽作准备。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让发动玩家从自己墓地选择1只符合条件的炎属性怪兽作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,s.filter2,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置操作信息：该效果涉及1只怪兽从墓地离开（移动到魔陷区），使相关『从墓地离开』的判定和应对效果能够正确运作。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	-- 设置操作信息：该效果将特殊召唤这张卡自身，以便『星尘龙』等针对特殊召唤的效果进行对应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②处理时：若对象仍与效果关联且不免疫此效果，则先将对象移动至原持有者魔陷区并变成永续魔法；随后若这张卡仍与效果关联，则将这张卡特殊召唤到己方场上。
function s.mvop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的墓地炎属性怪兽对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e)
		-- 若对象仍与效果关联且不免疫此效果，则将其移动至其原持有者的魔陷区，表侧表示放置，并立即适用其效果。
		and Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true) then
		-- 那只怪兽当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置。
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
		if c:IsRelateToEffect(e) then
			-- 将这张卡以表侧表示特殊召唤到己方场上（按通常特殊召唤流程处理）。
			Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
