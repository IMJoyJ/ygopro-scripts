--DNA改造手術
-- 效果：
-- 发动时宣言1个种族。只要这张卡在场上存在，场上的全部表侧表示的怪兽变成宣言的种族。
function c74701381.initial_effect(c)
	-- 发动时宣言1个种族。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c74701381.target)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，场上的全部表侧表示的怪兽变成宣言的种族。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetValue(c74701381.value)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
end
-- 卡片发动时的效果处理，让玩家宣言1个种族，并将宣言的种族保存到永续效果中，同时在卡片上显示宣言的种族
function c74701381.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向玩家发送选择宣言种族的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	-- 让玩家从所有种族中宣言1个种族
	local rc=Duel.AnnounceRace(tp,1,RACE_ALL)
	e:GetLabelObject():SetLabel(rc)
	e:GetHandler():SetHint(CHINT_RACE,rc)
end
-- 获取保存的宣言种族，作为改变种族效果的返回值
function c74701381.value(e,c)
	return e:GetLabel()
end
