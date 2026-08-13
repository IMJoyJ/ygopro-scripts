--ペインペインター
-- 效果：
-- 这张卡的卡名只要在场上表侧表示存在当作「僵尸带菌者」使用。此外，1回合1次，选择这张卡以外的自己场上最多2只不死族怪兽才能发动。选择的怪兽的等级直到结束阶段时变成2星。把这个效果适用的怪兽作为同调素材的场合，不是不死族怪兽的同调召唤不能使用。
function c21620076.initial_effect(c)
	-- 为这张卡注册卡名变更效果，使其在场上表侧表示时卡名当作「僵尸带菌者」。
	aux.EnableChangeCode(c,33420078)
	-- 此外，1回合1次，选择这张卡以外的自己场上最多2只不死族怪兽才能发动。选择的怪兽的等级直到结束阶段时变成2星。把这个效果适用的怪兽作为同调素材的场合，不是不死族怪兽的同调召唤不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21620076,0))  --"等级变化"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c21620076.lvtg)
	e2:SetOperation(c21620076.lvop)
	c:RegisterEffect(e2)
end
-- 定义等级变化效果的选择对象过滤条件：必须表侧表示、是不死族、等级不为2星且等级在1星以上。
function c21620076.lvfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and not c:IsLevel(2) and c:IsLevelAbove(1)
end
-- 等级变化效果的发动时点处理：进行取对象检查，并让玩家选择自己场上1～2只满足条件的表侧表示不死族怪兽作为对象。
function c21620076.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c21620076.lvfilter(chkc) end
	-- 效果发动合法性检查：确认自己场上存在至少1只满足过滤条件且不是本卡的怪兽可供选择。
	if chk==0 then return Duel.IsExistingTarget(c21620076.lvfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 显示选择框提示，提示玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从自己场上选择1～2只满足lvfilter条件且不是本卡的怪兽作为效果对象，并将这些卡设置为当前连锁的对象。
	Duel.SelectTarget(tp,c21620076.lvfilter,tp,LOCATION_MZONE,0,1,2,e:GetHandler())
end
-- 效果处理：对连锁对象中仍然关联的每只怪兽，分别赋予其等级变为2星的单方效果，以及作为同调素材时限制为仅限不死族怪兽的同调召唤使用的单方效果。
function c21620076.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 从当前连锁的对象卡组中，筛选出仍然与该效果保持关联的卡（即没有离场或失去联系的对象）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local tc=g:GetFirst()
	while tc do
		if tc:IsFaceup() then
			-- 选择的怪兽的等级直到结束阶段时变成2星。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(2)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 把这个效果适用的怪兽作为同调素材的场合，不是不死族怪兽的同调召唤不能使用。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
			e2:SetValue(c21620076.synlimit)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
		tc=g:GetNext()
	end
end
-- 同调素材限制判定：当怪兽作为同调素材时，若该素材怪兽不是不死族，则返回true表示不能将其作为同调素材。
function c21620076.synlimit(e,c)
	if not c then return false end
	return not c:IsRace(RACE_ZOMBIE)
end
