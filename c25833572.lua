--ゲート・ガーディアン
-- 效果：
-- 这张卡不能通常召唤。把自己场上的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」各1只解放的场合可以特殊召唤。
function c25833572.initial_effect(c)
	-- 记录该卡牌效果中涉及的其他卡片编号
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
-- 创建一个用于检查是否满足特定卡片编号条件的函数数组
c25833572.spchecks=aux.CreateChecks(Card.IsCode,{25955164,62340868,98434877})
-- 判断是否满足特殊召唤条件：场上有满足条件的卡片组可被解放
function c25833572.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家可解放的卡片组（不包括手卡）
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 检查是否存在满足条件的卡片组合，用于判断是否可以特殊召唤
	return g:CheckSubGroupEach(c25833572.spchecks,aux.mzctcheckrel,tp,REASON_SPSUMMON)
end
-- 设置选择解放卡片的处理函数
function c25833572.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家可解放的卡片组（不包括手卡）
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 向玩家发送提示信息，提示选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从符合条件的卡片组中选择满足条件的子组
	local sg=g:SelectSubGroupEach(tp,c25833572.spchecks,true,aux.mzctcheckrel,tp,REASON_SPSUMMON)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤后的处理：解放选定的卡片
function c25833572.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定卡片组解放，作为特殊召唤的代价
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
