--救世の儀式
-- 效果：
-- 「救世之美神 诺斯维姆科」的降临必需。必须从手卡·自己场上把等级合计直到7以上的怪兽解放。可以把自己墓地存在的这张卡从游戏中除外，这个回合自己场上表侧表示存在的1只仪式怪兽不会成为魔法·陷阱·效果怪兽的效果的对象。
function c60234913.initial_effect(c)
	-- 注册仪式召唤效果，用于召唤「救世之美神 诺斯维姆科」，解放等级合计需在7以上。
	aux.AddRitualProcGreaterCode(c,61757117)
	-- 可以把自己墓地存在的这张卡从游戏中除外，这个回合自己场上表侧表示存在的1只仪式怪兽不会成为魔法·陷阱·效果怪兽的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60234913,0))  --"仪式怪兽不会成为效果对象"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_GRAVE)
	-- 将此卡从墓地除外作为发动的代价。
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c60234913.uttg)
	e1:SetOperation(c60234913.utop)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的仪式怪兽。
function c60234913.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL)
end
-- 效果发动的目标选择阶段，确认并选择自己场上1只表侧表示的仪式怪兽作为对象。
function c60234913.uttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c60234913.filter(chkc) end
	-- 检查自己场上是否存在符合条件的表侧表示仪式怪兽。
	if chk==0 then return Duel.IsExistingTarget(c60234913.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的仪式怪兽作为效果对象。
	Duel.SelectTarget(tp,c60234913.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理阶段，使作为对象的怪兽在本回合内获得不成为效果对象的效果。
function c60234913.utop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 这个回合自己场上表侧表示存在的1只仪式怪兽不会成为魔法·陷阱·效果怪兽的效果的对象。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
