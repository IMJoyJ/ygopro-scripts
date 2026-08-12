--ペインペインター
-- 效果：
-- 这张卡的卡名只要在场上表侧表示存在当作「僵尸带菌者」使用。此外，1回合1次，选择这张卡以外的自己场上最多2只不死族怪兽才能发动。选择的怪兽的等级直到结束阶段时变成2星。把这个效果适用的怪兽作为同调素材的场合，不是不死族怪兽的同调召唤不能使用。
function c21620076.initial_effect(c)
	-- 使该卡在场上表侧表示存在时视为「僵尸带菌者」使用
	aux.EnableChangeCode(c,33420078)
	-- 1回合1次，选择这张卡以外的自己场上最多2只不死族怪兽才能发动。选择的怪兽的等级直到结束阶段时变成2星。把这个效果适用的怪兽作为同调素材的场合，不是不死族怪兽的同调召唤不能使用。
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
-- 筛选满足条件的怪兽：表侧表示、不死族、等级不是2、等级大于等于1
function c21620076.lvfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and not c:IsLevel(2) and c:IsLevelAbove(1)
end
-- 设置效果的目标选择函数，用于选择符合条件的怪兽
function c21620076.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c21620076.lvfilter(chkc) end
	-- 判断是否满足发动条件：场上存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c21620076.lvfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标怪兽，数量为1到2只
	Duel.SelectTarget(tp,c21620076.lvfilter,tp,LOCATION_MZONE,0,1,2,e:GetHandler())
end
-- 处理效果的发动，将目标怪兽等级变为2，并限制其不能作为非不死族怪兽的同调素材
function c21620076.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁中被选择的目标怪兽组，并筛选出与效果相关的怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local tc=g:GetFirst()
	while tc do
		if tc:IsFaceup() then
			-- 将目标怪兽的等级变为2
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(2)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 限制目标怪兽不能作为非不死族怪兽的同调素材
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
-- 判断目标怪兽是否为不死族，用于限制其不能作为非不死族怪兽的同调素材
function c21620076.synlimit(e,c)
	if not c then return false end
	return not c:IsRace(RACE_ZOMBIE)
end
