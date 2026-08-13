--サイバー・チュチュボン
-- 效果：
-- ①：这张卡可以从自己的手卡·场上把1只战士族或者天使族怪兽解放从手卡特殊召唤。
-- ②：这张卡为仪式召唤而被解放的场合，以自己墓地1张仪式魔法卡为对象才能发动。那张卡加入手卡。
function c42600274.initial_effect(c)
	-- ①：这张卡可以从自己的手卡·场上把1只战士族或者天使族怪兽解放从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetCondition(c42600274.hspcon)
	e1:SetTarget(c42600274.hsptg)
	e1:SetOperation(c42600274.hspop)
	c:RegisterEffect(e1)
	-- ②：这张卡为仪式召唤而被解放的场合，以自己墓地1张仪式魔法卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:SetCondition(c42600274.thcon)
	e2:SetTarget(c42600274.thtg)
	e2:SetOperation(c42600274.thop)
	c:RegisterEffect(e2)
end
-- 特殊召唤手续的解放素材过滤函数：判断怪兽是否满足作为解放素材的条件（战士族或天使族、控制者为自己，且解放后自己场上有空位）。
function c42600274.hspfilter(c,tp)
	-- 返回true的条件：c是战士族或天使族怪兽，控制者为tp，并且解放c后tp场上仍有可用的怪兽区空格。
	return c:IsRace(RACE_WARRIOR+RACE_FAIRY) and c:IsControler(tp) and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤规则效果的发动条件：若c为空则始终满足；否则检查tp是否存在至少1只满足条件的可解放怪兽，且解放后有空位。
function c42600274.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查tp的场上·手卡是否存在至少1张满足hspfilter条件的可解放怪兽（解放原因为特殊召唤，允许手卡素材，并排除这张卡自身）。
	return Duel.CheckReleaseGroupEx(tp,c42600274.hspfilter,1,REASON_SPSUMMON,true,e:GetHandler(),tp)
end
-- 特殊召唤手续的选择阶段：从tp可解放的怪兽中筛选出符合条件的怪兽，让玩家选择1只作为解放素材，并用LabelObject保存该卡；选择成功则返回true。
function c42600274.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取tp所有可解放的怪兽（包含手卡），过滤出满足hspfilter的候选卡，并排除这张卡自身。
	local g=Duel.GetReleaseGroup(tp,true,REASON_SPSUMMON):Filter(c42600274.hspfilter,c,tp)
	-- 向tp显示“请选择要解放的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤手续的处理：解放之前选择的素材怪兽，并给这张卡注册一个标志，用于客户端提示“出场方式为特殊召唤”。
function c42600274.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定的怪兽以“特殊召唤”为理由解放。
	Duel.Release(g,REASON_SPSUMMON)
	c:RegisterFlagEffect(0,RESET_EVENT+0x4fc0000,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(42600274,0))  --"出场方式为特殊召唤"
end
-- ②效果的发动条件：这张卡被解放的原因包含仪式召唤（REASON_RITUAL），即为仪式召唤而被解放。
function c42600274.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_RITUAL)
end
-- ②效果的对象过滤函数：判断墓地中的卡是否为仪式魔法卡（类型0x82=魔法卡+仪式类型）且能够加入手卡。
function c42600274.thfilter(c)
	return c:GetType()==0x82 and c:IsAbleToHand()
end
-- ②效果的发动与对象选择：从自己墓地选择1张仪式魔法卡作为取对象，并设置将对象加入手卡的操作信息。
function c42600274.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c42600274.thfilter(chkc) end
	-- 发动时检查自己墓地是否存在至少1张满足thfilter的仪式魔法卡可作为对象；若存在才能发动。
	if chk==0 then return Duel.IsExistingTarget(c42600274.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向tp显示“请选择要加入手卡的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1张满足条件的仪式魔法卡作为本效果的取对象卡片。
	local g=Duel.SelectTarget(tp,c42600274.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：本效果处理时会将该对象卡加入手卡，数量为1，归类为CATEGORY_TOHAND。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理：如果对象卡仍在墓地且与本效果有关联，则将其加入持有者手卡。
function c42600274.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出本效果发动时选择的取对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡加入其持有者的手卡，原因为效果处理。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
