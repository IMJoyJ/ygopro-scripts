--ゲート・ガーディアン
-- 效果：
-- 这张卡不能通常召唤。把自己场上的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」各1只解放的场合可以特殊召唤。
function c25833572.initial_effect(c)
	-- 给这张卡注册效果文本中记载的卡名代码，使系统识别其特殊召唤所需的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」；这是效果外文本的一部分。
	aux.AddCodeList(c,25955164,62340868,98434877)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把自己场上的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」各1只解放的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c25833572.spcon)
	e1:SetTarget(c25833572.sptg)
	e1:SetOperation(c25833572.spop)
	c:RegisterEffect(e1)
end
-- 为三只指定魔神分别生成卡名判定函数列表，用于后续筛选解放素材，实现“各1只”的卡名指定条件。
c25833572.spchecks=aux.CreateChecks(Card.IsCode,{25955164,62340868,98434877})
-- 定义特殊召唤规则效果的可用条件：检查当前玩家场上是否存在可解放的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」各1只，且解放后主怪兽区仍有空位。
function c25833572.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取当前玩家场上可解放的怪兽集合（本次解放原因为特殊召唤），用于判定和选择解放素材。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 检查该怪兽集合能否选出三只指定魔神各1只，同时满足解放后主怪兽区仍有空位，从而允许「门之守护神」以该方式特殊召唤。
	return g:CheckSubGroupEach(c25833572.spchecks,aux.mzctcheckrel,tp,REASON_SPSUMMON)
end
-- 定义特殊召唤规则效果的选择处理：在满足条件后，让玩家选择要解放的三只指定魔神，并保存选择结果供后续解放使用。
function c25833572.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 再次获取当前玩家场上可解放的怪兽集合（本次解放原因为特殊召唤），作为玩家选择解放素材的候选范围。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 向玩家显示“请选择要解放的卡”的提示信息，引导其选择本次特殊召唤所需的解放素材。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家从候选集合中按三只指定魔神各1只的方式选择一组解放素材，并校验解放后主怪兽区仍有空位；选中后将这组卡保存下来。
	local sg=g:SelectSubGroupEach(tp,c25833572.spchecks,true,aux.mzctcheckrel,tp,REASON_SPSUMMON)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 定义特殊召唤规则效果的解放处理：取出之前保存的解放素材组，将其解放以完成“解放的场合可以特殊召唤”的代价，并清理临时对象。
function c25833572.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将以特殊召唤为原因解放选中的怪兽组，实际支付“把自己场上的三只魔神各1只解放”的特殊召唤代价。
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
