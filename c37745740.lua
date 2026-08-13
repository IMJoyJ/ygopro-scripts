--EMガンバッター
-- 效果：
-- 「娱乐伙伴 弩弓蝗虫」的①②的效果1回合各能使用1次。
-- ①：把自己场上1只「娱乐伙伴」怪兽解放才能发动。给与对方解放的怪兽的等级×100伤害。
-- ②：把自己场上1只「娱乐伙伴」怪兽解放，以解放的怪兽以外的自己墓地1只「娱乐伙伴」怪兽为对象才能发动。那只怪兽加入手卡。
function c37745740.initial_effect(c)
	-- ①：把自己场上1只「娱乐伙伴」怪兽解放才能发动。给与对方解放的怪兽的等级×100伤害。
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
	-- ②：把自己场上1只「娱乐伙伴」怪兽解放，以解放的怪兽以外的自己墓地1只「娱乐伙伴」怪兽为对象才能发动。那只怪兽加入手卡。
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
-- ①效果的代价函数：检查能否解放场上1只「娱乐伙伴」怪兽，选择并解放，将解放怪兽的等级×100存入标签作为伤害值。
function c37745740.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只可解放的「娱乐伙伴」怪兽（非上级召唤用）。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x9f) end
	-- 向对方玩家提示己方发动了该效果，并显示效果描述文本。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 选择自己场上1只「娱乐伙伴」怪兽作为发动代价。
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x9f)
	e:SetLabel(g:GetFirst():GetLevel()*100)
	-- 将选择的怪兽解放，作为发动费用的代价处理。
	Duel.Release(g,REASON_COST)
end
-- ①效果发动时的目标设定：指定对方为伤害对象，设定伤害数值，并登记伤害效果的操作信息。
function c37745740.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设置为解放怪兽的等级×100，即伤害数值。
	Duel.SetTargetParam(e:GetLabel())
	-- 登记伤害效果的操作信息：目标为对方玩家，伤害值为e:GetLabel()中保存的数值。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
end
-- ①效果处理时的操作：从连锁信息中取出对象玩家和伤害数值，给对方造成效果伤害。
function c37745740.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象玩家和伤害参数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给对方玩家造成d点效果伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- ②效果的代价函数：解放自己场上1只「娱乐伙伴」怪兽，并将解放的怪兽记录到e:SetLabelObject，作为后续选择对象时的排除对象。
function c37745740.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只可解放的「娱乐伙伴」怪兽（非上级召唤用）。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x9f) end
	-- 向对方玩家提示己方发动了该效果，并显示效果描述文本。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 选择自己场上1只「娱乐伙伴」怪兽作为发动代价。
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x9f)
	e:SetLabelObject(g:GetFirst())
	-- 将选择的怪兽解放，作为发动费用的代价处理。
	Duel.Release(g,REASON_COST)
end
-- 墓地过滤函数：判断卡是否为「娱乐伙伴」怪兽且可以被加入手卡。
function c37745740.thfilter(c)
	return c:IsSetCard(0x9f) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果的取对象目标函数：从自己墓地选择1只「娱乐伙伴」怪兽作为对象（不能是解放的那只），并登记加入手卡的效果信息。
function c37745740.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c37745740.thfilter(chkc) and chkc~=e:GetLabelObject() end
	-- 检查自己墓地是否存在至少1只满足条件的「娱乐伙伴」怪兽，且排除解放的那只。
	if chk==0 then return Duel.IsExistingTarget(c37745740.thfilter,tp,LOCATION_GRAVE,0,1,e:GetLabelObject()) end
	-- 给玩家显示“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1只满足条件的「娱乐伙伴」怪兽作为对象，排除解放的那只。
	local g=Duel.SelectTarget(tp,c37745740.thfilter,tp,LOCATION_GRAVE,0,1,1,e:GetLabelObject())
	-- 登记回手卡的操作信息，目标为选择的墓地怪兽。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- ②效果处理时的操作：将取对象选中的墓地怪兽加入手卡。
function c37745740.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理中的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡送去持有者的手卡（加入手卡）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
