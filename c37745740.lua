--EMガンバッター
-- 效果：
-- 「娱乐伙伴 弩弓蝗虫」的①②的效果1回合各能使用1次。
-- ①：把自己场上1只「娱乐伙伴」怪兽解放才能发动。给与对方解放的怪兽的等级×100伤害。
-- ②：把自己场上1只「娱乐伙伴」怪兽解放，以解放的怪兽以外的自己墓地1只「娱乐伙伴」怪兽为对象才能发动。那只怪兽加入手卡。
function c37745740.initial_effect(c)
	-- 「娱乐伙伴 弩弓蝗虫」的①②的效果1回合各能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37745740,0))  --"效果伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,37745740)
	e1:SetCost(c37745740.cost)
	e1:SetTarget(c37745740.target)
	e1:SetOperation(c37745740.operation)
	c:RegisterEffect(e1)
	-- 「娱乐伙伴 弩弓蝗虫」的①②的效果1回合各能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37745740,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,37745741)
	e2:SetCost(c37745740.thcost)
	e2:SetTarget(c37745740.thtg)
	e2:SetOperation(c37745740.thop)
	c:RegisterEffect(e2)
end
-- 检查玩家场上是否存在至少1张满足条件的「娱乐伙伴」怪兽可解放
function c37745740.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在至少1张满足条件的「娱乐伙伴」怪兽可解放
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x9f) end
	-- 向对方玩家提示“对方选择了：效果伤害”
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 让玩家从场上选择1张满足条件的「娱乐伙伴」怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x9f)
	e:SetLabel(g:GetFirst():GetLevel()*100)
	-- 以REASON_COST原因解放目标怪兽
	Duel.Release(g,REASON_COST)
end
-- 设置效果的目标玩家为对方玩家
function c37745740.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的目标玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果的目标参数为解放怪兽等级×100
	Duel.SetTargetParam(e:GetLabel())
	-- 设置效果的操作信息为伤害效果，对象玩家为对方玩家，伤害值为解放怪兽等级×100
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
end
-- 以REASON_EFFECT原因给与对方玩家造成伤害
function c37745740.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以REASON_EFFECT原因给与对方玩家造成伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 检查玩家场上是否存在至少1张满足条件的「娱乐伙伴」怪兽可解放
function c37745740.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在至少1张满足条件的「娱乐伙伴」怪兽可解放
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x9f) end
	-- 向对方玩家提示“对方选择了：加入手卡”
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 让玩家从场上选择1张满足条件的「娱乐伙伴」怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x9f)
	e:SetLabelObject(g:GetFirst())
	-- 以REASON_COST原因解放目标怪兽
	Duel.Release(g,REASON_COST)
end
-- 定义墓地「娱乐伙伴」怪兽的过滤条件
function c37745740.thfilter(c)
	return c:IsSetCard(0x9f) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检查玩家墓地是否存在至少1张满足条件的「娱乐伙伴」怪兽可选择
function c37745740.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c37745740.thfilter(chkc) and chkc~=e:GetLabelObject() end
	-- 检查玩家墓地是否存在至少1张满足条件的「娱乐伙伴」怪兽可选择
	if chk==0 then return Duel.IsExistingTarget(c37745740.thfilter,tp,LOCATION_GRAVE,0,1,e:GetLabelObject()) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从墓地选择1张满足条件的「娱乐伙伴」怪兽作为对象
	local g=Duel.SelectTarget(tp,c37745740.thfilter,tp,LOCATION_GRAVE,0,1,1,e:GetLabelObject())
	-- 设置效果的操作信息为回手牌效果，对象为选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 将目标怪兽加入手牌
function c37745740.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以REASON_EFFECT原因加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
