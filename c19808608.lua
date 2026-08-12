--DDバフォメット
-- 效果：
-- ①：1回合1次，以「DD 巴风特」以外的自己场上1只「DD」怪兽为对象，宣言1～8的任意等级才能发动。那只怪兽直到回合结束时变成宣言的等级。这个效果的发动后，直到回合结束时自己不是「DD」怪兽不能特殊召唤。
function c19808608.initial_effect(c)
	-- ①：1回合1次，以「DD 巴风特」以外的自己场上1只「DD」怪兽为对象，宣言1～8的任意等级才能发动。那只怪兽直到回合结束时变成宣言的等级。这个效果的发动后，直到回合结束时自己不是「DD」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c19808608.lvtg)
	e1:SetOperation(c19808608.lvop)
	c:RegisterEffect(e1)
end
-- 定义目标筛选条件：表侧表示、卡名带有「DD」字段、不是「DD 巴风特」本身且等级大于0的怪兽
function c19808608.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xaf) and not c:IsCode(19808608) and c:GetLevel()>0
end
-- 效果的目标函数：确认存在可以成为对象的卡后，选择1只符合条件的怪兽作为对象，并让玩家宣言1～8的等级保存到效果标签中
function c19808608.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c19808608.filter(chkc) end
	-- 检查自己场上是否存在1只满足条件的表侧表示怪兽可以作为本效果的对象
	if chk==0 then return Duel.IsExistingTarget(c19808608.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家提示"请选择表侧表示的卡"，用于随后选择对象的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让自己玩家从自己场上选择1只满足条件的表侧表示怪兽，并将其设为当前效果的对象
	local g=Duel.SelectTarget(tp,c19808608.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local lv=g:GetFirst():GetLevel()
	-- 向玩家发出宣言等级的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	-- 让玩家宣言1～8的任意等级（排除对象怪兽当前的等级），并将宣言的等级保存到效果的Label中
	e:SetLabel(Duel.AnnounceLevel(tp,1,8,lv))
end
-- 效果的处理函数：将对象怪兽直到回合结束时的等级改为宣言的等级，并给自己附加直到回合结束时「DD」以外的怪兽不能特殊召唤的限制
function c19808608.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡（即选择的那只「DD」怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽直到回合结束时变成宣言的等级。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 这个效果的发动后，直到回合结束时自己不是「DD」怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c19808608.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 把不能特殊召唤的限制效果注册给发动这个效果的玩家
	Duel.RegisterEffect(e2,tp)
end
-- 定义特殊召唤限制的判定：只要不是「DD」怪兽就不能特殊召唤
function c19808608.splimit(e,c)
	return not c:IsSetCard(0xaf)
end
